###################################################################################
# Security Group for RDS
###################################################################################
module "security_group_rds_maria" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-rds-${var.rds_mariadb_name}"
  use_name_prefix = false
  description     = "PostgreSQL example security group"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-${var.rds_mariadb_name}"
    },
  )
}

module "security_group_oracle" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-rds-${var.rds_oracle_name}"
  use_name_prefix = false
  description     = "Oracle security group"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-${var.rds_oracle_name}"
    },
  )
}

module "security_group_custom_oracle_mig" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-rds-custom-oracle-mig"
  use_name_prefix = false
  description     = "Security group for Custom Oracle"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-rds-custom-oracle-mig"
    },
  )
}

module "security_group_aurora_postgresql_mig" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-rds-aurora-postgresql-mig"
  use_name_prefix = false
  description     = "Security group for Custom Oracle"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-rds-aurora-postgresql-mig"
    },
  )
}

###################################################################################
# Security Group for ELB
###################################################################################
module "security_group_alb_container" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-alb-container"
  use_name_prefix = false
  description     = "Security group for EKS ALB ingress"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-alb-container"
    },
  )
}

module "security_group_alb_vm" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-alb-vm"
  use_name_prefix = false
  description     = "Security group for VM ALB ingress"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-alb-vm"
    },
  )
}

###################################################################################
# Security Group for EC2
###################################################################################
module "security_group_ec2_sms" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-ec2-sms"
  use_name_prefix = false
  description     = "Security group for EC2 SMS"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-ec2-sms"
    },
  )
}

module "security_group_ec2_meta" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-ec2-meta"
  use_name_prefix = false
  description     = "Security group for EC2 Meta#"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-ec2-meta"
    },
  )
}

module "security_group_ec2_nexus" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-ec2-nexus"
  use_name_prefix = false
  description     = "Security group for EC2 Nexus"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-ec2-nexus"
    },
  )
}

module "security_group_ec2_mig" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  create  = var.create_security_group

  name            = "scg-${var.service}-${var.environment}-ec2-mig"
  use_name_prefix = false
  description     = "Security group for EC2 Migration"
  vpc_id          = data.aws_vpc.vpc.id

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-ec2-mig"
    },
  )
}