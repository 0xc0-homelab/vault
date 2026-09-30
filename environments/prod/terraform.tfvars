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

# The cluster's secrets, for External Secrets Operator to read.
kv_engines = {
  secret = "The cluster's secrets, read by External Secrets Operator"
}
