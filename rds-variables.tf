###################################################
# RDS Common Variables
###################################################
# create_db_subnet_group
variable "create_db_subnet_group" {
  description = "Whether to create a database subnet group"
  type        = bool
  default     = true
}

###################################################
# RDS MariaDB
###################################################
# RDS Name
variable "rds_mariadb_name" {
  description = "RDS Name"
  type        = string
  default     = "mariadb-solution"
}

# RDS Engine
variable "rds_mariadb_engine" {
  description = "RDS Engine"
  type        = string
  default     = "mariadb"
}

# RDS Engine Version
variable "rds_mariadb_engine_version" {
  description = "RDS Engine Version"
  type        = string
  default     = "10.11.8"
}

# RDS Inatance Class
variable "rds_mariadb_instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = ""
}

# RDS Family
variable "rds_mariadb_family" {
  description = "RDS DB parameter group"
  type        = string
  default     = "mariadb10.11"
}

# RDS Major Engine Version
variable "rds_mariadb_major_engine_version" {
  description = "RDS DB option group"
  type        = string
  default     = "10.11"
}

# RDS Allocated Storage
variable "rds_mariadb_allocated_storage" {
  description = "RDS Allocated Storage"
  type        = number
  default     = 500
}

# RDS DB Name
variable "rds_mariadb_db_name" {
  description = "RDS DB Name"
  type        = string
  default     = ""
}

# RDS MariaDB Username
variable "rds_mariadb_username" {
  description = "RDS MariaDB As-Is Username"
  type        = string
  default     = ""
}

# RDS MariaDB Port
variable "rds_mariadb_port" {
  description = "RDS MariaDB As-Is Port"
  type        = number
  default     = 3306
}

# Whether to create an MariaDB (True or False)
variable "create_mariadb" {
  description = "Whether to create an MariaDB As-Is"
  type        = bool
  default     = false
}

###################################################
# RDS Oracle
###################################################

# RDS Name
variable "rds_oracle_name" {
  description = "RDS Name"
  type        = string
  default     = "oracle-solution"
}

# RDS Engine
variable "rds_oracle_engine" {
  description = "RDS Engine"
  type        = string
  default     = "oracle-ee"
}

# RDS Engine Version
variable "rds_oracle_engine_version" {
  description = "RDS Engine Version"
  type        = string
  default     = "19"
}

# RDS Instance Class
variable "rds_oracle_instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = "db.t3.large"
}

# RDS Family
variable "rds_oracle_family" {
  description = "RDS DB parameter group"
  type        = string
  default     = "oracle-ee-19"
}

# RDS Major Engine Version
variable "rds_oracle_major_engine_version" {
  description = "RDS DB option group"
  type        = string
  default     = "19"
}

# RDS Allocated Storage
variable "rds_oracle_allocated_storage" {
  description = "RDS Allocated Storage"
  type        = number
  default     = 500
}

# RDS Name
variable "rds_oracle_db_name" {
  description = "RDS Database Name"
  type        = string
  default     = "oracle"
}

# RDS Oracle Username
variable "rds_oracle_username" {
  description = "RDS Oracle Username"
  type        = string
  default     = ""
}

# RDS Oracle Port
variable "rds_oracle_port" {
  description = "RDS Oracle Port"
  type        = number
  default     = 1521
}

# Whether to create an Oracle (True or False)
variable "create_oracle" {
  description = "Whether to create an Oracle"
  type        = bool
  default     = false
}

###################################################
# PostegreSQL Oracle
###################################################
# RDS Name
variable "rds_postgresql_name" {
  description = "RDS Name"
  type        = string
  default     = "postgresql-da"
}

# RDS Engine
variable "rds_postgresql_engine" {
  description = "RDS Engine"
  type        = string
  default     = "postgres"
}

# RDS Engine Version
variable "rds_postgresql_engine_version" {
  description = "RDS Engine Version"
  type        = string
  default     = "14"
}

# RDS Inatance Class
variable "rds_postgresql_instance_class" {
  description = "RDS Instance Class"
  type        = string
  default     = ""
}

# RDS Family
variable "rds_postgresql_family" {
  description = "RDS DB parameter group"
  type        = string
  default     = "postgres14"
}

# RDS Major Engine Version
variable "rds_postgresql_major_engine_version" {
  description = "RDS DB option group"
  type        = string
  default     = "14"
}

# RDS Allocated Storage
variable "rds_postgresql_allocated_storage" {
  description = "RDS Allocated Storage"
  type        = number
  default     = 500
}

# RDS DB Name
variable "rds_postgresql_db_name" {
  description = "RDS DB Name"
  type        = string
  default     = ""
}

# RDS PostgreSQL DA Username
variable "rds_postgresql_username" {
  description = "RDS PostgreSQL DA Username"
  type        = string
  default     = ""
}

# RDS PostgreSQL DA Password
variable "rds_postgresql_password" {
  description = "RDS PostgreSQL DA Password"
  type        = string
  default     = ""
}

# RDS PostgreSQL DA Port
variable "rds_postgresql_port" {
  description = "RDS PostgreSQL DA Port"
  type        = number
  default     = 1521
}

# Whether to create an PostgreSQL DA (True or False)
variable "create_postgresql" {
  description = "Whether to create an PostgreSQL DA"
  type        = bool
  default     = false
}
