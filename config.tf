################################################################################
# Config Resource (ap-northeast-2)
################################################################################

# locals {
#   config_custom_rules = {
#     for lambda_item in var.config_lambda_names_policys :
#     lambda_item[0] => {
#       name                = lambda_item[0]
#       actions             = lambda_item[1]
#       trigger_types       = lambda_item[2]
#       scope               = lambda_item[3]
#       lambda_function_arn = module.lambda_function[lambda_item[0]].lambda_function_arn
#     }
#   }
# }

# Configuration Recorder (모든 자원 기록)
resource "aws_config_configuration_recorder" "config_recorder_ap_northeast_2" {
  count    = var.create_config_ap_northeast_2 ? 1 : 0
  name     = "config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Delivery Channel
resource "aws_config_delivery_channel" "delivery_channel_ap_northeast_2" {
  count          = var.create_config_ap_northeast_2 ? 1 : 0
  name           = "config-delivery"
  s3_bucket_name = data.aws_s3_bucket.config.id
  depends_on     = [aws_config_configuration_recorder.config_recorder_ap_northeast_2]
}

# Start the recorder
resource "aws_config_configuration_recorder_status" "recorder_status_ap_northeast_2" {
  count      = var.create_config_ap_northeast_2 ? 1 : 0
  name       = aws_config_configuration_recorder.config_recorder_ap_northeast_2[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.delivery_channel_ap_northeast_2]
}

################################################################################
# Managed Config Rules
################################################################################

resource "aws_config_config_rule" "config_rule_managed_ap_northeast_2" {
  count = var.create_config_ap_northeast_2 ? length(var.config_managed_rules) : 0

  name        = "${var.config_managed_rules[count.index][0]}-${var.config_managed_rules[count.index][4]}"
  description = "Managed config rule for ${var.config_managed_rules[count.index][0]}"

  source {
    owner             = "AWS"
    source_identifier = var.config_managed_rules[count.index][1]
  }

  # input_parameters가 있을 때만 추가
  input_parameters = length(keys(var.config_managed_rules[count.index][3])) > 0 ? jsonencode(var.config_managed_rules[count.index][3]) : null

  # scope_resource_types가 있을 때만 동적 블록
  dynamic "scope" {
    for_each = length(var.config_managed_rules[count.index][2]) > 0 ? [1] : []
    content {
      compliance_resource_types = var.config_managed_rules[count.index][2]
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "cfr-${var.service}-${var.environment}-${var.config_managed_rules[count.index][0]}-${var.config_managed_rules[count.index][4]}"
    }
  )

  depends_on = [
    aws_config_configuration_recorder.config_recorder_ap_northeast_2,
    aws_config_configuration_recorder_status.recorder_status_ap_northeast_2,
    aws_config_delivery_channel.delivery_channel_ap_northeast_2
  ]
}

################################################################################
# Custom Config Rules (Lambda 기반)
################################################################################

resource "aws_config_config_rule" "config_rule_custom_ap_northeast_2" {
  count = var.create_config_ap_northeast_2 ? length(var.config_custom_rules) : 0

  name        = "${var.config_custom_rules[count.index][0]}-${var.config_custom_rules[count.index][5]}"
  description = "Custom config rule for ${var.config_custom_rules[count.index][0]}"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = module.lambda_function[var.config_custom_rules[count.index][0]].lambda_function_arn

    source_detail {
      event_source                = "aws.config"
      message_type                = contains(var.config_custom_rules[count.index][2], "CONFIGURATION_CHANGE") ? "ConfigurationItemChangeNotification" : "ScheduledNotification"
      maximum_execution_frequency = contains(var.config_custom_rules[count.index][2], "PERIODIC") ? "TwentyFour_Hours" : null
    }
  }

  dynamic "scope" {
    for_each = length(var.config_custom_rules[count.index][3]) > 0 ? [1] : []

    content {
      compliance_resource_types = var.config_custom_rules[count.index][3]
    }
  }

  input_parameters = length(var.config_custom_rules[count.index][4]) > 0 ? jsonencode(var.config_custom_rules[count.index][4]) : null

  tags = merge(
    local.tags,
    {
      "Name" = "cfr-${var.service}-${var.environment}-${var.config_custom_rules[count.index][0]}"
    }
  )

  # 반드시 Config Recorder/Status/Delivery Channel이 먼저 생성되어야 함
  depends_on = [
    aws_config_configuration_recorder.config_recorder_ap_northeast_2,
    aws_config_configuration_recorder_status.recorder_status_ap_northeast_2,
    aws_config_delivery_channel.delivery_channel_ap_northeast_2
  ]
}
