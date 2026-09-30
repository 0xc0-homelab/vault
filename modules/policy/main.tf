# One ACL policy, from its HCL.
resource "vault_policy" "main" {
  name   = var.name
  policy = var.policy
}
