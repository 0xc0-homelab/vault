resource "vault_auth_backend" "main" {
  type        = "kubernetes"
  path        = var.path
  description = "The cluster's service accounts, for Vault Secrets Operator"

  # Every namespace's way in: losing it takes each of its roles again.
  lifecycle {
    prevent_destroy = true
  }
}

# Vault runs in the cluster and reviews tokens with its own service account and
# CA (gitops, platform/vault): only the address is set.
resource "vault_kubernetes_auth_backend_config" "main" {
  backend         = vault_auth_backend.main.path
  kubernetes_host = var.kubernetes_host
}

# A label selector needs Vault's service account to read namespaces (gitops,
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
