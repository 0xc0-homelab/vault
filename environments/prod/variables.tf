variable "jwt_audience" {
  description = "The aud claim the CI jobs' OIDC tokens carry: Vault's own address, as the reusable workflows ask GitHub for it."
  type        = string
}

variable "jwt_roles" {
  description = "The JWT auth roles, by name: the claims a token must match, its policies, and its TTL in seconds."
  type = map(object({
    bound_claims = map(string)
    claims_type  = optional(string, "string")
    policies     = list(string)
    token_ttl    = optional(number, 1200)
  }))
}

variable "kubernetes_roles" {
  description = "Kubernetes auth roles, one per namespace, named after it: the namespace, its service accounts, their audience, its policies and TTL."
  type = map(object({
    namespace        = string
    service_accounts = list(string)
    audience         = optional(string, "vault")
    policies         = list(string)
    token_ttl        = optional(number, 3600)
  }))
  default = {}
}

variable "kv_engines" {
  description = "KV v2 secrets engines, by mount path, each with what it holds."
  type        = map(string)
}
