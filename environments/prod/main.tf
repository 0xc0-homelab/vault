# The prod configuration of the cluster's Vault. This root only calls modules
# from ../../modules; resources live there.

# How the CI gets in: GitHub Actions' OIDC tokens.
module "github_jwt" {
  source = "../../modules/github-jwt-auth"

  audience = var.jwt_audience
  roles    = var.jwt_roles
}

# One policy per file in policies/, named after it.
module "policies" {
  source   = "../../modules/policy"
  for_each = { for f in fileset("${path.root}/../../policies", "*.hcl") : trimsuffix(f, ".hcl") => f }

  name   = each.key
  policy = file("${path.root}/../../policies/${each.value}")
}

module "kv" {
  source   = "../../modules/kv"
  for_each = var.kv_engines

  path        = each.key
  description = each.value
}
