# traefik's namespace, through Vault Secrets Operator (its Kubernetes auth role):
# its own secrets, and the shared ones it uses, each by name.

path "platform/data/traefik/*" {
  capabilities = ["read"]
}

path "platform/data/shared/crowdsec-bouncer" {
  capabilities = ["read"]
}

path "platform/data/shared/ui-basic-auth" {
  capabilities = ["read"]
}
