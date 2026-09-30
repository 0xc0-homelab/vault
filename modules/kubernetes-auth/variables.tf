variable "path" {
  description = "Mount path of the auth method."
  type        = string
  default     = "kubernetes"
}

variable "kubernetes_host" {
  description = "The Kubernetes API, as Vault reaches it: from inside the cluster."
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "roles" {
  description = "Roles by name, one per namespace: its namespace, the service accounts it admits, the audience their tokens carry, its policies, and its TTL in seconds."
  type = map(object({
    namespace        = string
    service_accounts = list(string)
    audience         = optional(string, "vault")
    policies         = list(string)
    token_ttl        = optional(number, 3600)
  }))
  default = {}

  # A role admits one namespace and named service accounts, never a wildcard:
  # "*" would let any namespace read what the role reads.
  validation {
    condition = alltrue([
      for r in values(var.roles) : r.namespace != "*" && length(r.service_accounts) > 0 && !contains(r.service_accounts, "*")
    ])
    error_message = "A Kubernetes auth role binds one namespace and named service accounts, never \"*\"."
  }
}
