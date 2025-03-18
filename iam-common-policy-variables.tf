# Whether to create an IAM assumeable role (True or False)
variable "create_iam_policy" {
  description = "Whether to create an IAM policy"
  type        = bool
  default     = false
}

# KMS enc arn
variable "management_enc_kms_key_arn" {
  description = "KMS enc arn"
  type        = string
  default     = ""
}
