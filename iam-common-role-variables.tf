# Whether to create an IAM assumeable role (True or False)
variable "create_iam_assumeable_role" {
  description = "Whether to create an IAM assumeable role"
  type        = bool
  default     = true
}

# Management Account ID
variable "iam_management_account_id" {
  description = "Management Account ID"
  type        = string
  default     = ""
}

# Whether to create account password policy (True or False)
variable "create_account_password_policy" {
  description = "Whether to create account password policy"
  type        = bool
  default     = false
}

# Account Alias
variable "account_alias" {
  description = "Account Alias"
  type        = string
  default     = ""
}
