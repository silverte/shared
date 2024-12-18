# Database subnet group for vpc-esp-dev
resource "aws_db_subnet_group" "rds_subnet_group" {
  count       = var.create_db_subnet_group ? 1 : 0
  name        = "rdssg-${var.service}-${var.environment}"
  description = "Database subnet group for vpc-esp-dev"
  subnet_ids  = data.aws_subnets.database.ids
  tags = merge(
    local.tags,
    {
      Name = "rdssg-${var.service}-${var.environment}"
    },
  )
}

################################################################################
# RDS Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-rds
################################################################################
module "rds-maria" {
  source                    = "terraform-aws-modules/rds/aws"
  create_db_instance        = var.create_mariadb
  create_db_parameter_group = var.create_mariadb
  create_db_option_group    = var.create_mariadb

  identifier = "rds-${var.service}-${var.environment}-${var.rds_mariadb_name}"

  engine                          = var.rds_mariadb_engine
  engine_version                  = var.rds_mariadb_engine_version
  family                          = var.rds_mariadb_family               # DB parameter group
  major_engine_version            = var.rds_mariadb_major_engine_version # DB option group
  parameter_group_name            = "rdspg-${var.service}-${var.environment}-${var.rds_mariadb_name}"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "MariaDB parameter group for ${var.service}-${var.environment}-${var.rds_mariadb_name}"
  instance_class                  = var.rds_mariadb_instance_class
  option_group_name               = "rdsog-${var.service}-${var.environment}-${var.rds_mariadb_name}"
  option_group_use_name_prefix    = false
  option_group_description        = "MariaDB option group for ${var.service}-${var.environment}-${var.rds_mariadb_name}"

  storage_encrypted = true
  storage_type      = "gp3"
  # max_allocated_storage = var.rds_mariadb_as_allocated_storage * 1.1
  kms_key_id        = data.aws_kms_key.rds.arn
  allocated_storage = var.rds_mariadb_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                     = var.rds_mariadb_db_name
  username                    = var.rds_mariadb_username
  manage_master_user_password = true
  port                        = var.rds_mariadb_port

  multi_az               = false
  availability_zone      = element(local.azs, 0)
  db_subnet_group_name   = try(aws_db_subnet_group.rds_subnet_group[0].name, "")
  subnet_ids             = [element(data.aws_subnets.database.ids, 0)]
  vpc_security_group_ids = [module.security_group_rds_maria.security_group_id]

  #   maintenance_window              = "Mon:00:00-Mon:03:00"
  #   backup_window                   = "03:00-06:00"
  #   enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  #   create_cloudwatch_log_group     = true

  backup_retention_period    = 7
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  deletion_protection        = true

  #   performance_insights_enabled          = true
  #   performance_insights_retention_period = 7
  #   create_monitoring_role                = true
  #   monitoring_interval                   = 60
  #   monitoring_role_name                  = "example-monitoring-role-name"
  #   monitoring_role_use_name_prefix       = true
  #   monitoring_role_description           = "Description for monitoring role"

  #   parameters = [
  #     {
  #       name  = "autovacuum"
  #       value = 1
  #     },
  #     {
  #       name  = "client_encoding"
  #       value = "utf8"
  #     }
  #   ]

  tags = merge(
    local.tags,
    {
      "Name" = "rds-${var.service}-${var.environment}-${var.rds_mariadb_name}"
    },
  )
}

# ################################################################################
# # RDS Automated Backups Replication Module
# ################################################################################

# provider "aws" {
#   alias  = "region2"
#   region = local.region2
# }

# module "kms" {
#   source      = "terraform-aws-modules/kms/aws"
#   version     = "~> 1.0"
#   description = "KMS key for cross region automated backups replication"

#   # Aliases
#   aliases                 = [local.name]
#   aliases_use_name_prefix = true

#   key_owners = [data.aws_caller_identity.current.arn]

#   tags = local.tags

#   providers = {
#     aws = aws.region2
#   }
# }

# module "db_automated_backups_replication" {
#   source = "../../modules/db_instance_automated_backups_replication"

#   source_db_instance_arn = module.db.db_instance_arn
#   kms_key_arn            = module.kms.key_arn

#   providers = {
#     aws = aws.region2
#   }
# }

################################################################################
# RDS Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-rds
################################################################################

module "rds-oracle" {
  source                    = "terraform-aws-modules/rds/aws"
  create_db_instance        = var.create_oracle
  create_db_parameter_group = var.create_oracle
  create_db_option_group    = var.create_oracle

  identifier = "rds-${var.service}-${var.environment}-${var.rds_oracle_name}"

  engine                          = var.rds_oracle_engine
  engine_version                  = var.rds_oracle_engine_version
  family                          = var.rds_oracle_family               # DB parameter group
  major_engine_version            = var.rds_oracle_major_engine_version # DB option group
  parameter_group_name            = "rdspg-${var.service}-${var.environment}-${var.rds_oracle_name}"
  parameter_group_use_name_prefix = false
  parameter_group_description     = "DB parameter group for ${var.service}-${var.environment}-${var.rds_oracle_name}"
  instance_class                  = var.rds_oracle_instance_class
  license_model                   = "bring-your-own-license"
  option_group_name               = "rdsopt-${var.service}-${var.environment}-${var.rds_oracle_name}"
  option_group_use_name_prefix    = false
  option_group_description        = "Option Group for ${var.service}-${var.environment}-${var.rds_oracle_name}"

  storage_encrypted = true
  storage_type      = "gp3"
  # max_allocated_storage = var.rds_oracle_to_allocated_storage * 1.1
  kms_key_id        = data.aws_kms_key.rds.arn
  allocated_storage = var.rds_oracle_allocated_storage

  # Make sure that database name is capitalized, otherwise RDS will try to recreate RDS instance every time
  # Oracle database name cannot be longer than 8 characters
  db_name                     = var.rds_oracle_db_name
  username                    = var.rds_oracle_username
  manage_master_user_password = true
  port                        = var.rds_oracle_port

  multi_az               = false
  availability_zone      = element(local.azs, 0)
  db_subnet_group_name   = try(aws_db_subnet_group.rds_subnet_group[0].name, "")
  subnet_ids             = [element(data.aws_subnets.database.ids, 0)]
  vpc_security_group_ids = [module.security_group_oracle.security_group_id]

  # maintenance_window              = "Mon:00:00-Mon:03:00"
  # backup_window                   = "03:00-06:00"
  # enabled_cloudwatch_logs_exports = ["alert", "audit"]
  # create_cloudwatch_log_group     = true

  backup_retention_period    = 7
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  deletion_protection        = true

  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7
  # create_monitoring_role                = true

  # See here for support character sets https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.OracleCharacterSets.html
  character_set_name       = "AL32UTF8"
  nchar_character_set_name = "AL16UTF16"

  tags = merge(
    local.tags,
    {
      "Name" = "rds-${var.service}-${var.environment}-${var.rds_oracle_name}"
    },
  )
}

################################################################################
# RDS Automated Backups Replication Module
################################################################################

# module "kms" {
#   source      = "terraform-aws-modules/kms/aws"
#   version     = "~> 1.0"
#   description = "KMS key for cross region automated backups replication"

#   # Aliases
#   aliases                 = [local.name]
#   aliases_use_name_prefix = true

#   key_owners = [data.aws_caller_identity.current.arn]

#   tags = local.tags

#   providers = {
#     aws = aws.region2
#   }
# }

# module "db_automated_backups_replication" {
#   source = "../../modules/db_instance_automated_backups_replication"

#   source_db_instance_arn = module.db.db_instance_arn
#   kms_key_arn            = module.kms.key_arn

#   providers = {
#     aws = aws.region2
#   }
# }
