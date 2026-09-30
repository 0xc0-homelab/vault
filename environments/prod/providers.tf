# Address and token come from the environment: VAULT_ADDR, and VAULT_TOKEN from
# the CI job's JWT login (or the operator's, over WARP, run by hand). The token
# is used as it is, not traded for a child one: the CI roles cannot create
# tokens, and it expires with its role's TTL anyway.
provider "vault" {
  skip_child_token = true
}
