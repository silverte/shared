################################################################################
# Config Module
# reference: https://github.com/cloudposse/terraform-example-module
################################################################################

################################################################################
# Config Module
################################################################################

module "config" {
  source    = "cloudposse/config/aws"
  count     = var.create_config ? 1 : 0
  namespace = "ezwel"

  # 글로벌 자원(예: IAM) 수집 리전
  global_resource_collector_region = var.region

  # Config 기록용 S3 버킷 (기존에 생성된 버킷 사용)
  s3_bucket_id  = data.aws_s3_bucket.config.id
  s3_bucket_arn = data.aws_s3_bucket.config.arn

  # 기존에 생성된 IAM Role 사용 (role-esp-config)
  create_iam_role = false
  iam_role_arn    = aws_iam_role.config.arn

  # --------------------------------------------------------
  # Recording strategy: 모든 자원 연속 녹화 (기본값 오버라이드)
  # --------------------------------------------------------
  recording_mode = {
    recording_frequency = "CONTINUOUS"
    # recording_mode_override는 생략하여 기본 동작 유지
  }

  # --------------------------------------------------------
  # 단일 Managed Rule: cloudtrail-enabled만 활성화
  # --------------------------------------------------------
  managed_rules = {
    "cloudtrail-enabled" = {
      description      = "Checks whether AWS CloudTrail is enabled in your AWS account"
      identifier       = "CLOUD_TRAIL_ENABLED" #  [oai_citation_attribution:4‡GitHub](https://github.com/cloudposse/terraform-aws-config)
      trigger_type     = "PERIODIC"
      input_parameters = {} # 파라미터 없음
      tags             = {} # 태그 없음
      enabled          = true
    }
  }
}
