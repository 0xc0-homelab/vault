# No stored secret, but it can rewrite any policy, its own included: it is
# effectively an admin, guarded by its role (main only, behind the operator's
# approval).

path "sys/auth" {
  capabilities = ["read"]
}
path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "sudo"]
}
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/mounts" {
  capabilities = ["read"]
}
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/policies/acl" {
  capabilities = ["list"]
}
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# The provider reads a policy through the older sys/policy endpoint.
path "sys/policy" {
  capabilities = ["read", "list"]
}
path "sys/policy/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# RustFS, this repo's OpenTofu state: the only secret it reads.
path "ci/data/shared/rustfs" {
  capabilities = ["read"]
}
