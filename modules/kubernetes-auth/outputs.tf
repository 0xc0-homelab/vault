output "path" {
  description = "Mount path of the auth method."
  value       = vault_auth_backend.main.path
}

output "accessor" {
  description = "Accessor of the auth method: templated policies name its entity aliases by it."
  value       = vault_auth_backend.main.accessor
}
