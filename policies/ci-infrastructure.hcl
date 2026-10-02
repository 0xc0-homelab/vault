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

# The one path across a boundary: ArgoCD's admin bcrypt is ArgoCD's, so it
# lives under platform/, but Ansible writes it when it installs ArgoCD
# (infrastructure, the argocd role). By name, and the bcrypt only: the
# password itself is in ops/, which no machine reads.
path "platform/data/argocd/admin" {
  capabilities = ["read"]
}
