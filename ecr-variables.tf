# Whether to create an ECR App (True or False)
variable "create_ecr" {
  description = "Whether to create an ECR App"
  type        = bool
  default     = false
}

# ECR Name
variable "ecr_names" {
  description = "ECR Names"
  type        = list(string)
  default     = []
}
