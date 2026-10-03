# VAULT_TOKEN is used as is, not traded for a child token: the CI roles
# cannot create tokens.
provider "vault" {
  skip_child_token = true
}
