# Whether to create an S3 Bucket App (True or False)
variable "create_s3_bucket" {
  description = "Whether to create an S3 Bucket App"
  type        = bool
  default     = false
}

# S3 Bucket names
variable "s3_bucket_names" {
  description = "List of S3 Bucket names"
  type        = list(string)
  default     = []
}
