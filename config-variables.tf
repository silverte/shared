# Whether to create an Config Seoul (True or False)
variable "create_config_ap_northeast_2" {
  description = "Whether to create an Config App"
  type        = bool
  default     = false
}

# Whether to create an Config Virginia (True or False)
variable "create_config_us_east_1" {
  description = "Whether to create an Config App"
  type        = bool
  default     = false
}

# Whether to create an Config Lambda (True or False)
variable "create_config_lambda" {
  description = "Whether to create an Config Lambda"
  type        = bool
  default     = true
}

# Config Managed Rule Info.
variable "config_managed_rules" {
  description = "Config Lambda (Names and Policy)"
  type = list(
    tuple([
      string,
      string,
      list(string),
      map(string),
      string
    ])
  )
  default = []
}


# Config Custom Rule Info.
variable "config_custom_rules" {
  description = "Config Lambda (Names and Policy)"
  type = list(
    tuple([
      string,
      list(string),
      list(string),
      list(string),
      map(string),
      string
    ])
  )
  default = []
}
