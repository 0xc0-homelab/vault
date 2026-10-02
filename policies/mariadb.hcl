# mariadb's namespace, through Vault Secrets Operator (its Kubernetes auth
# role): its own secrets, the root password, and each application's database
# password, by name: its databases Job creates the user with it.

path "platform/data/mariadb/*" {
  capabilities = ["read"]
}

# Mautic's database user (gitops#73).
path "apps/data/mautic/database" {
  capabilities = ["read"]
}
