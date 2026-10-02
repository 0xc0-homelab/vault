# Data for this environment. Vault's address and token come from the
# environment (VAULT_ADDR, VAULT_TOKEN).

# What the reusable tofu workflows ask GitHub for as the token's audience:
# vault-addr, the address the job logs in to.
jwt_audience = "https://vault.int.0xc0.cc"

# The vault repo's CI (operator decision, 2026-09-30: JWT with GitHub's OIDC
# tokens). A PR plans read-only from any ref; only main, inside the production
# environment that waits for the operator's approval, may write. Each role
# also binds the reusable workflow, as it is on .github's main.
jwt_roles = {
  "terraform-plan" = {
    bound_claims = {
      repository       = "0xc0-homelab/vault"
      job_workflow_ref = "0xc0-homelab/.github/.github/workflows/tofu-plan.yml@refs/heads/main"
    }
    policies = ["terraform-plan"]
  }
  "terraform" = {
    bound_claims = {
      repository       = "0xc0-homelab/vault"
      ref              = "refs/heads/main"
      environment      = "production"
      job_workflow_ref = "0xc0-homelab/.github/.github/workflows/tofu-apply.yml@refs/heads/main"
    }
    policies = ["terraform"]
  }

  # The other repos' CI (operator decision, 2026-10-01: every secret in
  # Vault): each job reads its repo's ci/<repo>/* and the shared
  # secrets it uses, from any of .github's reusable workflows on main. Reading
  # them writes nothing: what changes infrastructure still waits for the
  # production environment's approval.
  "github" = {
    claims_type = "glob"
    bound_claims = {
      repository       = "0xc0-homelab/.github"
      job_workflow_ref = "0xc0-homelab/.github/.github/workflows/*@refs/heads/main"
    }
    policies = ["ci-github"]
  }
  "infrastructure" = {
    claims_type = "glob"
    bound_claims = {
      repository       = "0xc0-homelab/infrastructure"
      job_workflow_ref = "0xc0-homelab/.github/.github/workflows/*@refs/heads/main"
    }
    policies = ["ci-infrastructure"]
  }
}

# One KV v2 engine per trust boundary (operator decision, 2026-09-30), and
# ops/ for what only people use (2026-10-02). Paths inside are
# <owner>/<name>: the namespace, the repo or the service, then the secret.
kv_engines = {
  platform = "The cluster's shared services, one path per namespace, read by Vault Secrets Operator"
  apps     = "The applications, one path per namespace, read by Vault Secrets Operator"
  ci       = "The pipelines, one path per repo, read by that repo's CI jobs over JWT"
  ops      = "What only people use: UI logins and passwords in clear. No machine has a policy on it"
}

# Vault Secrets Operator's way in, one role per namespace, named after it: the
# namespace's vault-secrets service account (gitops, <component>/vault-secrets.yaml)
# and the policy of the same name.
kubernetes_roles = {
  "cert-manager" = {
    namespace        = "cert-manager"
    service_accounts = ["vault-secrets"]
    policies         = ["cert-manager"]
  }
  "external-dns" = {
    namespace        = "external-dns"
    service_accounts = ["vault-secrets"]
    policies         = ["external-dns"]
  }
  "crowdsec" = {
    namespace        = "crowdsec"
    service_accounts = ["vault-secrets"]
    policies         = ["crowdsec"]
  }
  "traefik" = {
    namespace        = "traefik"
    service_accounts = ["vault-secrets"]
    policies         = ["traefik"]
  }
  "longhorn-system" = {
    namespace        = "longhorn-system"
    service_accounts = ["vault-secrets"]
    policies         = ["longhorn-system"]
  }
  "openobserve" = {
    namespace        = "openobserve"
    service_accounts = ["vault-secrets"]
    policies         = ["openobserve"]
  }
  "openobserve-collector" = {
    namespace        = "openobserve-collector"
    service_accounts = ["vault-secrets"]
    policies         = ["openobserve-collector"]
  }
  "mariadb" = {
    namespace        = "mariadb"
    service_accounts = ["vault-secrets"]
    policies         = ["mariadb"]
  }
}
