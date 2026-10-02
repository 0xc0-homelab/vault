# openobserve's namespace, through Vault Secrets Operator (its Kubernetes auth
# role): its own secrets.

path "platform/data/openobserve/*" {
  capabilities = ["read"]
}
