variable "path" {
  description = "Mount path of the auth method."
  type        = string
  default     = "jwt"
}

variable "issuer" {
  description = "GitHub Actions' OIDC issuer: discovery URL and bound issuer."
  type        = string
  default     = "https://token.actions.githubusercontent.com"
}

variable "audience" {
  description = "The aud claim a token must carry: what the workflow asks GitHub for (vault-action's jwtGithubAudience)."
  type        = string
}

variable "roles" {
  description = "Roles by name: the claims a token must match exactly, the policies it gets, and its TTL in seconds."
  type = map(object({
    bound_claims = map(string)
    # "string": exact match; "glob": * matches, in every claim of the role.
    claims_type = optional(string, "string")
    policies    = list(string)
    token_ttl   = optional(number, 1200)
  }))

  validation {
    condition     = alltrue([for r in values(var.roles) : contains(keys(r.bound_claims), "repository")])
    error_message = "Every role must bind the repository claim: without it, any repository on GitHub could log in."
  }

  validation {
    condition     = alltrue([for r in values(var.roles) : contains(["string", "glob"], r.claims_type) && !strcontains(r.bound_claims["repository"], "*")])
    error_message = "claims_type is string or glob, and the repository claim is never a glob."
  }
}
