variable "jwt_audience" {
  description = "The aud claim the CI jobs' OIDC tokens carry: Vault's own address, as the reusable workflows ask GitHub for it."
  type        = string
}

variable "jwt_roles" {
  description = "The JWT auth roles, by name: the claims a token must match, its policies, and its TTL in seconds."
  type = map(object({
    bound_claims = map(string)
    policies     = list(string)
    token_ttl    = optional(number, 1200)
  }))
}

variable "kv_engines" {
  description = "KV v2 secrets engines, by mount path, each with what it holds."
  type        = map(string)
}
