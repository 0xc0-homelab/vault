# vault

The configuration of the cluster's Vault, as OpenTofu: auth methods and their
roles, policies, secret engines. Vault itself is deployed by `gitops`
(`platform/vault`); this repo configures what runs.

```
environments/prod/   the root: only calls modules
modules/             github-jwt-auth, policy, kv
policies/            one ACL policy per file, named after it
secrets/             tofu.sops.yaml: the RustFS state keys
```

State: `homelab/vault/prod.tfstate` in RustFS.

## Secrets: the standard

One KV v2 engine per trust boundary, never one for everything, so a policy
for one never reaches another:

| Engine | Holds | Read by |
|---|---|---|
| `platform/` | the cluster's shared services | Vault Secrets Operator, per namespace |
| `apps/` | the applications | Vault Secrets Operator, per namespace |
| `ci/` | what the pipelines use (Proxmox, Cloudflare, RustFS, the runners' App) | each repo's CI jobs, over JWT |

Dynamic engines (`pki/`, `database/`) come when something needs them.

- **Paths:** `<engine>/<owner>/<name>`. The owner is the namespace, or the
  repo under `ci/`, and it is what a policy scopes to. Everything is
  lowercase and kebab-case: `platform/grafana/admin`, `ci/infrastructure/proxmox`.
- **Keys inside a secret:** `snake_case`, so they map to a Kubernetes Secret
  as they are: `username`, `password`, `api_token`.
- **Metadata:** every secret carries `custom_metadata` `owner` and
  `rotated_at`.
- **Who reads:** a namespace's Kubernetes auth role reads only
  `<engine>/<namespace>/*`. A repo's JWT role reads only `ci/<repo>/*`. There
  is no global reader.
- **Shared secrets: one secret, one path, never a copy.** A credential more
  than one consumer uses lives once, at `<engine>/shared/<name>`
  (`platform/shared/cloudflare-dns`, `ci/shared/rustfs`), and each consumer's
  policy grants it by name, next to its own paths. Never `shared/*` whole:
  who shares what is written in the policies, and reviewed in their PRs.
  Rotating it is one write, and every consumer follows.
- **Who writes:** whoever holds the secret, the operator or a rotation job.
  Never this repo: it defines engines, roles and policies, never values.

## Writing a secret

The operator writes, over WARP, with a token that may. Nothing a secret or a
token holds ever reaches a screen, a shell history or a command line:

- `vault login -no-print`: `vault login` alone prints the token it stores.
- The value on stdin, `key=-`, straight from where it lives, never pasted:

```sh
cd ~/git/github/0xc0-homelab/workspace/infrastructure
K='sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml -n vault exec -i vault-0 --'
ssh -t -i ~/.ssh/0xc0-homelab ops@10.10.4.21 "${K/exec -i/exec -it} vault login -no-print"

mise exec -- sops decrypt --extract '["CLOUDFLARE_API_TOKEN"]' secrets/tofu.sops.yaml \
  | ssh -i ~/.ssh/0xc0-homelab ops@10.10.4.21 "$K vault kv put -mount=platform shared/cloudflare api_token=-"
ssh -i ~/.ssh/0xc0-homelab ops@10.10.4.21 "$K vault kv metadata put -mount=platform \
  -custom-metadata=owner=operator -custom-metadata=rotated_at=$(date +%F) shared/cloudflare"

ssh -i ~/.ssh/0xc0-homelab ops@10.10.4.21 "$K rm -f /home/vault/.vault-token"
```

## Loading the CI's secrets from SOPS, once

Every secret moves to Vault and SOPS goes away (operator decision,
2026-10-01). `scripts/load-from-sops` reads each key of the SOPS files in
`.github` and `infrastructure` into memory and writes it to its `ci/` path as
JSON on stdin, with `owner` and `rotated_at=bootstrap`. It prints only paths
and key counts:

```sh
cd ~/git/github/0xc0-homelab/workspace/vault
export VAULT_ADDR=https://vault.int.0xc0.cc
mise exec -- vault login -no-print          # a token that may write ci/
mise exec -- scripts/load-from-sops
rm -f ~/.vault-token
```

Then the operator rotates each secret by hand, here, and every consumer
follows.

## How CI gets in

No Vault credential is stored anywhere. Each job logs in with the OIDC token
GitHub issues it (JWT auth, `hashicorp/vault-action`, in the reusable tofu
workflows in `0xc0-homelab/.github`):

| Role | Who | Policy |
|---|---|---|
| `terraform-plan` | any ref of this repo, through `.github`'s plan workflow on `main`: a PR's plan | `terraform-plan`: reads its own configuration |
| `terraform` | `main`, through `.github`'s run workflow on `main`, inside the `production` environment, after the operator's approval | `terraform`: manages the configuration |

The other repos' CI reads its secrets with one role per repo:

| Role | Who | Policy |
|---|---|---|
| `github` | `.github`, from any of its own reusable workflows on `main` | `ci-github`: `ci/github/*`, `ci/shared/rustfs` |
| `infrastructure` | `infrastructure`, from any of `.github`'s reusable workflows on `main` | `ci-infrastructure`: `ci/infrastructure/*`, `ci/shared/rustfs`, `ci/shared/cloudflare` |

A plan and a real run read the same secrets, so one role serves both: what
changes infrastructure still waits for the `production` environment's
approval, not for Vault.

Neither of this repo's own policies grants a stored secret, but for its
state's (`ci/shared/rustfs`). `terraform` can still rewrite any policy,
its own included, so it is effectively an admin: what guards it is its role's
binding and the operator's approval of every run from `main`.

The CI VMs reach Vault at `https://vault.int.0xc0.cc`, the internal VIP,
through an `/etc/hosts` entry (infrastructure, the `github_runner` role).

## Bootstrap, once: the first apply is local

The CI can only log in once its auth method and roles exist. So the first
apply runs from the operator's laptop, over WARP, with the root token (operator
decision, 2026-09-30): the only apply of this repo that ever runs outside the
pipeline. It creates everything in `environments/prod` at once, the CI's way
in included; from then on every change goes through a PR and the pipeline.

```sh
# From this repo's root, over WARP (Vault on the internal VIP, RustFS for the
# state). The root token goes into the environment only: read -s keeps it out
# of the shell history and off the screen.
export VAULT_ADDR=https://vault.int.0xc0.cc
read -rs VAULT_TOKEN && export VAULT_TOKEN

scripts/tofu prod init
scripts/tofu prod plan      # read it: the JWT auth, its two roles, the two policies, the KV engine
scripts/tofu prod apply

unset VAULT_TOKEN
```

Then check the CI gets in: open a PR here. Its plan logs in as
`terraform-plan` and shows no changes. The root token is not needed again.
Revoke it once there is another admin way in (OIDC, next).

The first engine, `secret/`, gave way to one per boundary before it held
anything. `prevent_destroy` keeps tofu from removing it, so the operator
disables it by hand first, once, over WARP: `vault secrets disable secret`.
The next plan finds it gone, drops it from the state, and destroys nothing.

## Running by hand

Over WARP, with a token in `VAULT_TOKEN`:

```sh
export VAULT_ADDR=https://vault.int.0xc0.cc
scripts/tofu prod plan
```

Past the bootstrap, changes run from the pipeline only, never from here.
