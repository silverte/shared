# create_security_group rule
variable "create_security_group_rule_permanent" {
  description = "Whether to create a security grou rule(permanent)"
  type        = bool
  default     = true
}

# create_security_group rule
variable "create_security_group_rule_temporary" {
  description = "Whether to create a security grou rule(temporary)"
  type        = bool
  default     = true
}
