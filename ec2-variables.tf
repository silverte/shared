# EC2 Root Volume size
variable "ec2_root_volume_size" {
  description = "EC2 Root Volume size"
  type        = number
  default     = 30
}

# EC2 AMI Filter value
variable "ec2_ami_filter_value" {
  description = "EC2 AMI Filter value"
  type        = string
  default     = "al2023-ami-2023.5.20240805.0-kernel-6.1-arm64"
}


# Whether to create an EC2 IMDG (True or False)
variable "create_ec2_mig_db" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_mig_db_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_mig_db_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

