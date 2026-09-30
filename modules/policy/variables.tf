variable "name" {
  description = "Policy name."
  type        = string
}

variable "policy" {
  description = "The policy itself, in Vault's HCL."
  type        = string
}
