# The .github repo's CI (org Terraform): its own secrets, and the shared ones
# it uses, each by name.

path "ci/data/github/*" {
  capabilities = ["read"]
}

# RustFS, the OpenTofu state.
path "ci/data/shared/rustfs" {
  capabilities = ["read"]
}
