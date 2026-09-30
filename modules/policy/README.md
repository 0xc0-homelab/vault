# policy

One Vault ACL policy, from its HCL. The root keeps each policy as a file in
`policies/`, named after it.

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
| [vault_policy.main](https://registry.terraform.io/providers/hashicorp/vault/5.12.0/docs/resources/policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Policy name. | `string` | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | The policy itself, in Vault's HCL. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_name"></a> [name](#output\_name) | Policy name. |
<!-- END_TF_DOCS -->
