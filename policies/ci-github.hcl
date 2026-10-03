path "ci/data/github/*" {
  capabilities = ["read"]
}

# RustFS, the OpenTofu state.
path "ci/data/shared/rustfs" {
  capabilities = ["read"]
}
