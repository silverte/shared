################################################################################
# Config Module (us-east-1)
################################################################################

# Configuration Recorder
resource "aws_config_configuration_recorder" "this" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types = [
      "AWS::ACM::Certificate",
      "AWS::CloudFront::Distribution",
      "AWS::WAF::WebACL",
      "AWS::WAFRegional::WebACL",
      "AWS::Route53::HostedZone",
      "AWS::Route53::RecordSet"
    ]
  }
}

# Delivery Channel
resource "aws_config_delivery_channel" "this" {
  provider       = aws.virginia
  count          = var.create_config_us_east_1 ? 1 : 0
  name           = "config-delivery"
  s3_bucket_name = data.aws_s3_bucket.config.id
  depends_on     = [aws_config_configuration_recorder.this]
}

# Start the recorder
resource "aws_config_configuration_recorder_status" "this" {
  provider   = aws.virginia
  count      = var.create_config_us_east_1 ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

# Config Rules
resource "aws_config_config_rule" "cloudfront_associated_with_waf" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "cloudfront-associated-with-waf-medium"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_ASSOCIATED_WITH_WAF"
  }

  description = "Managed rule for cloudfront associated with waf"
  scope {
    compliance_resource_types = ["AWS::CloudFront::Distribution"]
  }

  depends_on = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-cloudfront-associated-with-waf-medium"
  })
}

resource "aws_config_config_rule" "cloudfront_custom_ssl_certificate" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "cloudfront-custom-ssl-certificate-high"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_CUSTOM_SSL_CERTIFICATE"
  }

  description = "Managed rule for cloudfront custom ssl certificate"
  depends_on  = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-cloudfront-custom-ssl-certificate-high"
  })
}

resource "aws_config_config_rule" "cloudfront_s3_origin_access_control_enabled" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "cloudfront-s3-origin-access-control-enabled-medium"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_S3_ORIGIN_ACCESS_CONTROL_ENABLED"
  }

  description = "Managed rule for cloudfront s3 origin access control enabled"
  depends_on  = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-cloudfront-s3-origin-access-control-enabled-medium"
  })
}

resource "aws_config_config_rule" "cloudfront_viewer_policy_https" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "cloudfront-viewer-policy-https-high"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDFRONT_VIEWER_POLICY_HTTPS"
  }

  description = "Managed rule for cloudfront viewer policy https"
  depends_on  = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-cloudfront-viewer-policy-https-high"
  })
}

resource "aws_config_config_rule" "waf_global_webacl_not_empty" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "waf-global-webacl-not-empty-high"

  source {
    owner             = "AWS"
    source_identifier = "WAF_GLOBAL_WEBACL_NOT_EMPTY"
  }

  description = "Managed rule for waf global webacl not empty"
  depends_on  = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-waf-global-webacl-not-empty-high"
  })
}

resource "aws_config_config_rule" "acm_certificate_expiration_check" {
  provider = aws.virginia
  count    = var.create_config_us_east_1 ? 1 : 0
  name     = "acm-certificate-expiration-check-medium"

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  input_parameters = jsonencode({
    daysToExpiration = "45"
  })

  description = "Managed rule for acm certificate expiration check"
  scope {
    compliance_resource_types = ["AWS::ACM::Certificate"]
  }

  depends_on = [aws_config_configuration_recorder_status.this]

  tags = merge(local.tags, {
    Name = "cfr-${var.service}-${var.environment}-acm-certificate-expiration-check-medium"
  })
}
