# longhorn-system's namespace, through Vault Secrets Operator (its Kubernetes auth role):
# its own secrets, and the shared ones it uses, each by name.

path "platform/data/longhorn-system/*" {
  capabilities = ["read"]
}

path "platform/data/shared/ui-basic-auth" {
  capabilities = ["read"]
}
