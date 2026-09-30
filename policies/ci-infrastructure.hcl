# The infrastructure repo's CI (OpenTofu, Packer, Ansible): its own secrets,
# and the shared ones it uses, each by name.

path "ci/data/infrastructure/*" {
  capabilities = ["read"]
}

# RustFS, the OpenTofu state.
path "ci/data/shared/rustfs" {
  capabilities = ["read"]
}

# Cloudflare: the tunnels, Zero Trust and the DNS.
path "ci/data/shared/cloudflare" {
  capabilities = ["read"]
}
