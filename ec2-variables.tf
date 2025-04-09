# EC2 Root Volume size
variable "ec2_root_volume_size" {
  description = "EC2 Root Volume size"
  type        = number
  default     = 30
}

# EC2 AMI ID
variable "ec2_ami_id" {
  description = "EC2 AMI id"
  type        = string
  default     = ""
}

# EC2 Instant Profile
variable "ec2_profile" {
  description = "EC2 Profile"
  type        = string
  default     = ""
}

# EC2 Tags
variable "create_ec2_tags" {
  description = "EC2 Tags"
  type        = string
  default     = ""
}

####################################################
##################### ezjobs01 #####################
####################################################

# Whether to create an EC2 ezjobs01 (True or False)
variable "create_ec2_ezjobs01" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_ezjobs01_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_ezjobs01_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_ezjobs01_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

####################################################
##################### ezjobs02 #####################
####################################################

# Whether to create an EC2 WhaTap (True or False)
variable "create_ec2_ezjobs02" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_ezjobs02_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_ezjobs02_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_ezjobs02_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

##################################################
##################### whatap (dev) ###############
##################################################

# Whether to create an EC2 WhaTap (True or False)
variable "create_ec2_whatap_dev" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_whatap_dev_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_whatap_dev_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_whatap_dev_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

##################################################
##################### whatap (stg) ###############
##################################################

# Whether to create an EC2 WhaTap (True or False)
variable "create_ec2_whatap_stg" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_whatap_stg_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_whatap_stg_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_whatap_stg_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

####################################################
####################### nexus ######################
####################################################

# Whether to create an EC2 NEXUS (True or False)
variable "create_ec2_nexus" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_nexus_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_nexus_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_nexus_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

####################################################
##################### metasharp ####################
####################################################

# Whether to create an EC2 NEXUS (True or False)
variable "create_ec2_metasharp" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_metasharp_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_metasharp_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_metasharp_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}


####################################################
####################### sms ########################
####################################################

# Whether to create an EC2 SMS (True or False)
variable "create_ec2_sms" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_sms_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_sms_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_sms_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}

####################################################
####################### mig ########################
####################################################

# Whether to create an EC2 SMS (True or False)
variable "create_ec2_mig" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_mig_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_mig_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_mig_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}



####################################################
#################### test(temp) ####################
####################################################

# Whether to create an EC2 SMS (True or False)
variable "create_ec2_test" {
  description = "Whether to create an EC2 IMDG"
  type        = bool
  default     = false
}

# EC2 Instance Type
variable "ec2_test_instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t4g.medium"
}

# EC2 EBS Volume size
variable "ec2_test_ebs_volume_size" {
  description = "EC2 EBS Volume size"
  type        = number
  default     = 100
}

# EC2 Private IP address
variable "ec2_test_private_ip" {
  description = "EC2 Private IP address"
  type        = string
  default     = ""
}
