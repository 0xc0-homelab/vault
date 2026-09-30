# kubernetes-auth

Vault's Kubernetes auth method, for the cluster Vault runs in. A workload logs
in with its service account's token, and Vault checks it with the cluster's
TokenReview, using its own service account and CA: the only configuration is
the API's address.

One role per namespace, named after it. A role admits only that namespace's
service accounts, with the audience their tokens carry, and gets its policies:
as a rule, one that reads `platform/<namespace>/*` or `apps/<namespace>/*`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 5.12.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 5.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [vault_auth_backend.main](https://registry.terraform.io/providers/hashicorp/vault/5.12.0/docs/resources/auth_backend) | resource |
| [vault_kubernetes_auth_backend_config.main](https://registry.terraform.io/providers/hashicorp/vault/5.12.0/docs/resources/kubernetes_auth_backend_config) | resource |
| [vault_kubernetes_auth_backend_role.main](https://registry.terraform.io/providers/hashicorp/vault/5.12.0/docs/resources/kubernetes_auth_backend_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_kubernetes_host"></a> [kubernetes\_host](#input\_kubernetes\_host) | The Kubernetes API, as Vault reaches it: from inside the cluster. | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_path"></a> [path](#input\_path) | Mount path of the auth method. | `string` | `"kubernetes"` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Roles by name, one per namespace: its namespace, the service accounts it admits, the audience their tokens carry, its policies, and its TTL in seconds. | <pre>map(object({<br/>    namespace        = string<br/>    service_accounts = list(string)<br/>    audience         = optional(string, "vault")<br/>    policies         = list(string)<br/>    token_ttl        = optional(number, 3600)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_path"></a> [path](#output\_path) | Mount path of the auth method. |
<!-- END_TF_DOCS -->
