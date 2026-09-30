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

## How CI gets in

No Vault credential is stored anywhere. Each job logs in with the OIDC token
GitHub issues it (JWT auth, `hashicorp/vault-action`, in the reusable tofu
workflows in `0xc0-homelab/.github`):

| Role | Who | Policy |
|---|---|---|
| `terraform-plan` | any ref of this repo, through `.github`'s plan workflow on `main`: a PR's plan | `terraform-plan`: reads its own configuration |
| `terraform` | `main`, through `.github`'s run workflow on `main`, inside the `production` environment, after the operator's approval | `terraform`: manages the configuration |

Neither policy grants a stored secret. `terraform` can still rewrite any policy,
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
