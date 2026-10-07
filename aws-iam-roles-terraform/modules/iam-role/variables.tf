variable "create_inline_policy" {
  description = "Whether to create the inline policy. Must be a literal true/false, not derived from a resource attribute."
  type        = bool
  default     = false
}

variable "name" {
  description = "IAM role name."
  type        = string
}

variable "description" {
  description = "Human-readable role description."
  type        = string
  default     = ""
}

variable "trusted_principal_arns" {
  description = "Principals allowed to assume the role (the trust policy: WHO)."
  type        = list(string)
}

variable "require_mfa" {
  description = "Require MFA to assume the role."
  type        = bool
  default     = false
}

variable "managed_policy_arns" {
  description = "AWS-managed or customer-managed policy ARNs to attach."
  type        = list(string)
  default     = []
}

variable "inline_policy_json" {
  description = "Custom permissions policy as JSON (WHAT). Null means none."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session length in seconds (3600-43200)."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "tags" {
  description = "Tags applied to the role."
  type        = map(string)
  default     = {}
}
