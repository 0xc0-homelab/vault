# crowdsec's namespace, through Vault Secrets Operator (its Kubernetes auth role):
# its own secrets, and the shared ones it uses, each by name.

path "platform/data/crowdsec/*" {
  capabilities = ["read"]
}

path "platform/data/shared/crowdsec-bouncer" {
  capabilities = ["read"]
}
