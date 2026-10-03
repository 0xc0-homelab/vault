resource "vault_mount" "main" {
  path        = var.path
  type        = "kv"
  description = var.description
  options = {
    version = "2"
  }

  # Recreating the mount deletes every secret in it.
  lifecycle {
    prevent_destroy = true
  }
}
