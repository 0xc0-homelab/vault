# mautic's namespace, through Vault Secrets Operator (its Kubernetes auth
# role): its own secrets. The admin's login (ops/mautic/admin) is a person's:
# no machine reads it.

path "apps/data/mautic/*" {
  capabilities = ["read"]
}
