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
}

# One KV v2 engine per trust boundary (operator decision, 2026-09-30). Paths
# inside are <owner>/<name>: the namespace or the repo, then the secret.
kv_engines = {
  platform = "The cluster's shared services, one path per namespace, read by Vault Secrets Operator"
  apps     = "The applications, one path per namespace, read by Vault Secrets Operator"
  ci       = "The pipelines, one path per repo, read by that repo's CI jobs over JWT"
}

# Vault Secrets Operator's way in, one role per namespace. None yet: each comes
# with the first secret of its namespace.
kubernetes_roles = {}
