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

# Across a boundary: ArgoCD's admin bcrypt, which Ansible writes into the
# cluster (the argocd role). The password itself stays in ops/.
path "platform/data/argocd/admin" {
  capabilities = ["read"]
}
