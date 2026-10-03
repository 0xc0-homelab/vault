resource "vault_policy" "main" {
  name   = var.name
  policy = var.policy
}
