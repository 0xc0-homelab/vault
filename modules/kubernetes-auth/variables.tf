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
  description = "Roles by name: the namespace it admits, or the labels the namespaces it admits carry; the service accounts it admits, the audience their tokens carry, its policies, and its TTL in seconds."
  type = map(object({
    namespace        = optional(string)
    namespace_labels = optional(map(string))
    service_accounts = list(string)
    audience         = optional(string, "vault")
    policies         = list(string)
    token_ttl        = optional(number, 3600)
  }))
  default = {}

  # A wildcard would let any namespace read what the role reads.
  validation {
    condition = alltrue([
      for r in values(var.roles) :
      (r.namespace == null) != (r.namespace_labels == null) &&
      try(r.namespace != "*", true) && try(length(r.namespace_labels) > 0, true) &&
      length(r.service_accounts) > 0 && !contains(r.service_accounts, "*")
    ])
    error_message = "A Kubernetes auth role binds either one namespace or a non-empty set of namespace labels, and named service accounts, never \"*\"."
  }
}
