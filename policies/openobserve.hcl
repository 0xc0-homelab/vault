# openobserve's namespace, through Vault Secrets Operator (its Kubernetes auth
# role): its own secrets, and the shared ones it uses, each by name.

path "platform/data/openobserve/*" {
  capabilities = ["read"]
}

# The root user, also the collector's ingestion credential.
path "platform/data/shared/openobserve-root" {
  capabilities = ["read"]
}
