# mariadb's namespace, through Vault Secrets Operator (its Kubernetes auth
# role): its own secrets, the root password. Each application's database
# password is that application's, granted here by name when it arrives.

path "platform/data/mariadb/*" {
  capabilities = ["read"]
}
