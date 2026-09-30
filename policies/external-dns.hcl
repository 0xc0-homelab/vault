# external-dns's namespace, through Vault Secrets Operator (its Kubernetes auth role):
# its own secrets, and the shared ones it uses, each by name.

path "platform/data/external-dns/*" {
  capabilities = ["read"]
}

# The Cloudflare API token: DNS-01 challenges and DNS records.
path "platform/data/shared/cloudflare" {
  capabilities = ["read"]
}
