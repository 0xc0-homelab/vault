# Kubernetes auth: a workload logs in with its service account's token, and
# Vault checks it with the cluster's TokenReview. Vault runs in that cluster,
# so it uses its own service account and CA for that (the chart's auth
# delegator binding, gitops platform/vault): nothing to configure but the
# address. Vault Secrets Operator logs in this way for each namespace.

resource "vault_auth_backend" "main" {
  type        = "kubernetes"
  path        = var.path
  description = "The cluster's service accounts, for Vault Secrets Operator"

  # Every namespace's way in: losing it takes each of its roles again.
  lifecycle {
    prevent_destroy = true
  }
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend         = vault_auth_backend.main.path
  kubernetes_host = var.kubernetes_host
}

# One role per namespace, or one for every namespace carrying a label (the
# applications'): the service accounts it admits, and its policies. A label
# selector needs Vault's own service account to read namespaces (gitops,
# platform/vault).
resource "vault_kubernetes_auth_backend_role" "main" {
  for_each = var.roles

  backend   = vault_auth_backend.main.path
  role_name = each.key

  bound_service_account_names      = each.value.service_accounts
  bound_service_account_namespaces = each.value.namespace == null ? null : [each.value.namespace]
  audience                         = each.value.audience

  bound_service_account_namespace_selector = each.value.namespace_labels == null ? null : jsonencode({
    matchLabels = each.value.namespace_labels
  })

  token_policies = each.value.policies
  token_ttl      = each.value.token_ttl
  token_max_ttl  = each.value.token_ttl
}
