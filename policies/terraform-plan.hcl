# The vault repo's CI, planning a PR: it reads the configuration it manages
# (its auth methods, JWT and Kubernetes, the policies, the mounts), to diff
# it, and changes nothing. No secret, but for its own state's.

path "sys/auth" {
  capabilities = ["read"]
}
path "sys/auth/*" {
  capabilities = ["read"]
}
path "auth/jwt/*" {
  capabilities = ["read", "list"]
}
path "auth/kubernetes/*" {
  capabilities = ["read", "list"]
}

path "sys/mounts" {
  capabilities = ["read"]
}
path "sys/mounts/*" {
  capabilities = ["read"]
}

path "sys/policies/acl" {
  capabilities = ["list"]
}
path "sys/policies/acl/*" {
  capabilities = ["read", "list"]
}

# The provider reads a policy through the older sys/policy endpoint.
path "sys/policy" {
  capabilities = ["read", "list"]
}
path "sys/policy/*" {
  capabilities = ["read", "list"]
}

# RustFS, this repo's OpenTofu state: the only secret it reads.
path "ci/data/shared/rustfs" {
  capabilities = ["read"]
}
