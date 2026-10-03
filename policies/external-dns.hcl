path "platform/data/external-dns/*" {
  capabilities = ["read"]
}

# The Cloudflare API token: DNS-01 challenges and DNS records.
path "platform/data/shared/cloudflare" {
  capabilities = ["read"]
}
