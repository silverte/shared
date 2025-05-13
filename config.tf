################################################################################
# Config Module
# reference: https://github.com/cloudposse/terraform-example-module
################################################################################

locals {
  config_custom_rules = {
    for lambda_item in var.config_lambda_names_policys :
    lambda_item[0] => {
      name                = lambda_item[0]
      actions             = lambda_item[1]
      trigger_types       = lambda_item[2]
      scope               = lambda_item[3]
      lambda_function_arn = module.lambda_function[lambda_item[0]].lambda_function_arn
    }
  }
}

module "config_ap_northeast_2" {
  source    = "cloudposse/config/aws"
  count     = var.create_config_ap_northeast-2 ? 1 : 0
  namespace = "ezwel"

  global_resource_collector_region = var.region

  s3_bucket_id  = data.aws_s3_bucket.config.id
  s3_bucket_arn = data.aws_s3_bucket.config.arn

  create_iam_role = false
  iam_role_arn    = aws_iam_role.config[0].arn

  recording_mode = {
    recording_frequency = "CONTINUOUS"
  }

  managed_rules = {
    "cloudtrail-enabled-high" = {
      description      = "Checks whether AWS CloudTrail is enabled in your AWS account"
      identifier       = "CLOUD_TRAIL_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-cloudtrail-enabled-high"
        },
      )
      enabled = true
    },
    "access-keys-rotated-medium" = {
      description  = "Managed rule for access keys rotated"
      identifier   = "ACCESS_KEYS_ROTATED"
      trigger_type = "PERIODIC"
      input_parameters = {
        maxAccessKeyAge = "365"
      }
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-access-keys-rotated-medium"
        },
      )
      enabled = true
    },
    "acm-certificate-expiration-check-medium" = {
      description  = "Managed rule for acm certificate expiration check"
      identifier   = "ACM_CERTIFICATE_EXPIRATION_CHECK"
      trigger_type = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters = {
        daysToExpiration : "45"
      }
      scope_resource_types = [
        "AWS::ACM::Certificate"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-acm-certificate-expiration-check-medium"
        },
      )
      enabled = true
    },
    "alb-http-to-https-redirection-check-medium" = {
      description      = "Managed rule for alb http to https redirection check"
      identifier       = "ALB_HTTP_TO_HTTPS_REDIRECTION_CHECK"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::ElasticLoadBalancingV2::LoadBalancer"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-alb-http-to-https-redirection-check-medium"
        },
      )
      enabled = true
    },
    "cloud-trail-log-file-validation-enabled-medium" = {
      description      = "Managed rule for cloud trail log file validation enabled"
      identifier       = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-cloud-trail-log-file-validation-enabled-medium"
        },
      )
      enabled = true
    },
    "cmk-backing-key-rotation-enabled-high" = {
      description      = "Managed rule for cmk backing key rotation enabled"
      identifier       = "CMK_BACKING_KEY_ROTATION_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::KMS::Key"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-cmk-backing-key-rotation-enabled-high"
        },
      )
      enabled = true
    },
    "dynamodb-last-backup-recovery-point-created-medium" = {
      description      = "Managed rule for dynamodb last backup recovery point created"
      identifier       = "DYNAMODB_LAST_BACKUP_RECOVERY_POINT_CREATED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::DynamoDB::Table"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-dynamodb-last-backup-recovery-point-created-medium"
        },
      )
      enabled = true
    },
    "ecr-private-image-scanning-enabled-high" = {
      description      = "Managed rule for ecr private image scanning enabled"
      identifier       = "ECR_PRIVATE_IMAGE_SCANNING_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::ECR::Repository"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-ecr-private-image-scanning-enabled-high"
        },
      )
      enabled = true
    },
    "ecs-task-definition-log-configuration-high" = {
      description          = "Managed rule for ecs task definition log configuration"
      identifier           = "ECS_TASK_DEFINITION_LOG_CONFIGURATION"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::ECS::TaskDefinition"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-ecs-task-definition-log-configuration-high"
        },
      )
      enabled = true
    },
    "ec2-instance-no-public-ip-high" = {
      description          = "Managed rule for ec2 instance no public ip"
      identifier           = "EC2_INSTANCE_NO_PUBLIC_IP"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::Instance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-ec2-instance-no-public-ip-high"
        },
      )
      enabled = true
    },
    "efs-encrypted-check-medium" = {
      description          = "Managed rule for efs encrypted check"
      identifier           = "EFS_ENCRYPTED_CHECK"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::EFS::FileSystem"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-efs-encrypted-check-medium"
        },
      )
      enabled = true
    },
    "eip-attached-low" = {
      description          = "Managed rule for eip attached"
      identifier           = "EIP_ATTACHED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::EIP"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-eip-attached-low"
        },
      )
      enabled = true
    },
    "eks-cluster-log-enabled-medium" = {
      description  = "Managed rule for eks cluster log enabled"
      identifier   = "EKS_CLUSTER_LOG_ENABLED"
      trigger_type = "CONFIGURATION_CHANGE"
      input_parameters = {
        logTypes = "api,audit,authenticator"
      }
      scope_resource_types = ["AWS::EKS::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-eks-cluster-log-enabled-medium"
        },
      )
      enabled = true
    },
    "eks-endpoint-no-public-access-high" = {
      description          = "Managed rule for eks endpoint no public access"
      identifier           = "EKS_ENDPOINT_NO_PUBLIC_ACCESS"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::EKS::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-eks-endpoint-no-public-access-high"
        },
      )
      enabled = true
    },
    "elasticache-repl-grp-encrypted-at-rest-medium" = {
      description          = "Managed rule for elasticache repl grp encrypted at rest"
      identifier           = "ELASTICACHE_REPL_GRP_ENCRYPTED_AT_REST"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::ElastiCache::ReplicationGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-elasticache-repl-grp-encrypted-at-rest-medium"
        },
      )
      enabled = true
    },
    "elasticache-repl-grp-encrypted-in-transit-medium" = {
      description          = "Managed rule for elasticache repl grp encrypted in transit"
      identifier           = "ELASTICACHE_REPL_GRP_ENCRYPTED_IN_TRANSIT"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::ElastiCache::ReplicationGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-elasticache-repl-grp-encrypted-in-transit-medium"
        },
      )
      enabled = true
    },
    "encrypted-volumes-medium" = {
      description          = "Managed rule for encrypted volumes"
      identifier           = "ENCRYPTED_VOLUMES"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::Volume"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-encrypted-volumes-medium"
        },
      )
      enabled = true
    },
    "iam-group-has-users-check-low" = {
      description      = "Managed rule for iam group has users check"
      identifier       = "IAM_GROUP_HAS_USERS_CHECK"
      trigger_type     = "CONFIGURATION_CHANGE"
      input_parameters = {}
      scope_resource_types = [
        "AWS::IAM::Group",
        "AWS::IAM::User"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-group-has-users-check-low"
        },
      )
      enabled = true
    },
    "iam-password-policy-medium" = {
      description  = "Managed rule for iam password policy"
      identifier   = "IAM_PASSWORD_POLICY"
      trigger_type = "PERIODIC"
      input_parameters = {
        MinimumPasswordLength   = "8"
        PasswordReusePrevention = "3"
      }
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-password-policy-medium"
        },
      )
      enabled = true
    },
    "iam-policy-no-statements-with-admin-access-medium" = {
      description          = "Managed rule for iam policy no statements with admin access"
      identifier           = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::IAM::Policy"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-policy-no-statements-with-admin-access-medium"
        },
      )
      enabled = true
    },

    "iam-root-access-key-check-high" = {
      description      = "Managed rule for iam root access key check"
      identifier       = "IAM_ROOT_ACCESS_KEY_CHECK"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-root-access-key-check-high"
        },
      )
      enabled = true
    },
    "iam-user-no-policies-check-medium" = {
      description          = "Managed rule for iam user no policies check"
      identifier           = "IAM_USER_NO_POLICIES_CHECK"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::IAM::User"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-user-no-policies-check-medium"
        },
      )
      enabled = true
    },
    "iam-user-unused-credentials-check-high" = {
      description  = "Managed rule for iam user unused credentials check"
      identifier   = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
      trigger_type = "PERIODIC"
      input_parameters = {
        maxCredentialUsageAge = "90"
      }
      scope_resource_types = [
        "AWS::IAM::User"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-iam-user-unused-credentials-check-high"
        },
      )
      enabled = true
    },
    "mfa-enabled-for-iam-console-access-high" = {
      description      = "Managed rule for mfa enabled for iam console access"
      identifier       = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::IAM::User"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-mfa-enabled-for-iam-console-access-high"
        },
      )
      enabled = true
    },
    "multi-region-cloudtrail-enabled-high" = {
      description      = "Managed rule for multi region cloudtrail enabled"
      identifier       = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-multi-region-cloudtrail-enabled-high"
        },
      )
      enabled = true
    },
    "rds-aurora-mysql-audit-logging-enabled-high" = {
      description          = "Managed rule for rds aurora mysql audit logging enabled"
      identifier           = "RDS_AURORA_MYSQL_AUDIT_LOGGING_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBCluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-aurora-mysql-audit-logging-enabled-high"
        },
      )
      enabled = true
    },
    "rds-cluster-encrypted-at-rest-high" = {
      description          = "Managed rule for rds cluster encrypted at rest"
      identifier           = "RDS_CLUSTER_ENCRYPTED_AT_REST"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBCluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-cluster-encrypted-at-rest-high"
        },
      )
      enabled = true
    },
    "rds-in-backup-plan-medium" = {
      description          = "Managed rule for rds in backup plan"
      identifier           = "RDS_IN_BACKUP_PLAN"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-in-backup-plan-medium"
        },
      )
      enabled = true
    },
    "rds-instance-deletion-protection-enabled-medium" = {
      description          = "Managed rule for rds instance deletion protection enabled"
      identifier           = "RDS_INSTANCE_DELETION_PROTECTION_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-instance-deletion-protection-enabled-medium"
        },
      )
      enabled = true
    },
    "rds-instance-public-access-check-high" = {
      description          = "Managed rule for rds instance public access check"
      identifier           = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-instance-public-access-check-high"
        },
      )
      enabled = true
    },
    "rds-logging-enabled-high" = {
      description  = "Managed rule for rds logging enabled"
      identifier   = "RDS_LOGGING_ENABLED"
      trigger_type = "CONFIGURATION_CHANGE"
      input_parameters = {
        additionalLogs = "aurora:audit,maria:audit,oracle:audit"
      }
      scope_resource_types = ["AWS::RDS::DBInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-logging-enabled-high"
        },
      )
      enabled = true
    },
    "rds-resources-protected-by-backup-plan-medium" = {
      description      = "Managed rule for rds resources protected by backup plan"
      identifier       = "RDS_RESOURCES_PROTECTED_BY_BACKUP_PLAN"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      scope_resource_types = [
        "AWS::RDS::DBInstance",
        "AWS::RDS::DBCluster"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-resources-protected-by-backup-plan-medium"
        },
      )
      enabled = true
    },
    "rds-snapshot-encrypted-medium" = {
      description      = "Managed rule for rds snapshot encrypted"
      identifier       = "RDS_SNAPSHOT_ENCRYPTED"
      trigger_type     = "CONFIGURATION_CHANGE"
      input_parameters = {}
      scope_resource_types = [
        "AWS::RDS::DBSnapshot",
        "AWS::RDS::DBClusterSnapshot"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-snapshot-encrypted-medium"
        },
      )
      enabled = true
    },
    "rds-storage-encrypted-medium" = {
      description          = "Managed rule for rds storage encrypted"
      identifier           = "RDS_STORAGE_ENCRYPTED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-storage-encrypted-medium"
        },
      )
      enabled = true
    },
    "redshift-audit-logging-enabled-medium" = {
      description          = "Managed rule for redshift audit logging enabled"
      identifier           = "REDSHIFT_AUDIT_LOGGING_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::Redshift::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-redshift-audit-logging-enabled-medium"
        },
      )
      enabled = true
    },
    "redshift-backup-enabled-medium" = {
      description          = "Managed rule for redshift backup enabled"
      identifier           = "REDSHIFT_BACKUP_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::Redshift::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-redshift-backup-enabled-medium"
        },
      )
      enabled = true
    },
    "redshift-cluster-kms-enabled-medium" = {
      description          = "Managed rule for redshift cluster kms enabled"
      identifier           = "REDSHIFT_CLUSTER_KMS_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::Redshift::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-redshift-cluster-kms-enabled-medium"
        },
      )
      enabled = true
    },
    "redshift-cluster-public-access-check-high" = {
      description          = "Managed rule for redshift cluster public access check"
      identifier           = "REDSHIFT_CLUSTER_PUBLIC_ACCESS_CHECK"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::Redshift::Cluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-redshift-cluster-public-access-check-high"
        },
      )
      enabled = true
    },
    "redshift-require-tls-ssl-medium" = {
      description      = "Managed rule for redshift require tls ssl"
      identifier       = "REDSHIFT_REQUIRE_TLS_SSL"
      trigger_type     = "CONFIGURATION_CHANGE"
      input_parameters = {}
      scope_resource_types = [
        "AWS::Redshift::Cluster",
        "AWS::Redshift::ClusterParameterGroup"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-redshift-require-tls-ssl-medium"
        },
      )
      enabled = true
    },

    "root-account-mfa-enabled-high" = {
      description      = "Managed rule for root account mfa enabled"
      identifier       = "ROOT_ACCOUNT_MFA_ENABLED"
      trigger_type     = "PERIODIC"
      input_parameters = {}
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-root-account-mfa-enabled-high"
        },
      )
      enabled = true
    },
    "restricted-common-ports01-high" = {
      description  = "Managed rule for restricted common ports01"
      identifier   = "RESTRICTED_INCOMING_TRAFFIC"
      trigger_type = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters = {
        blockedPort1 = 20,
        blockedPort2 = 21,
        blockedPort3 = 23,
        blockedPort4 = 3389
      }
      scope_resource_types = ["AWS::EC2::SecurityGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-restricted-common-ports-high"
        },
      )
      enabled = true
    },
    "restricted-common-ports02-high" = {
      description  = "Managed rule for restricted common ports02"
      identifier   = "RESTRICTED_INCOMING_TRAFFIC"
      trigger_type = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters = {
        blockedPort1 = 5432,
        blockedPort2 = 54323,
        blockedPort3 = 1521,
        blockedPort4 = 3306
      }
      scope_resource_types = ["AWS::EC2::SecurityGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-restricted-common-ports-high"
        },
      )
      enabled = true
    },
    "vpc-sg-open-only-to-authorized-ports-high" = {
      description  = "Managed rule for vpc sg open only to authorized ports"
      identifier   = "VPC_SG_OPEN_ONLY_TO_AUTHORIZED_PORTS"
      trigger_type = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters = {
        authorizedTcpPorts = "80,443"
      }
      scope_resource_types = ["AWS::EC2::SecurityGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-vpc-sg-open-only-to-authorized-ports-high"
        },
      )
      enabled = true
    },
    "restricted-ssh-high" = {
      description          = "Managed rule for restricted ssh"
      identifier           = "INCOMING_SSH_DISABLED"
      trigger_type         = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::SecurityGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-restricted-ssh-high"
        },
      )
      enabled = true
    },
    "sagemaker-notebook-no-direct-internet-access-medium" = {
      description          = "Managed rule for sagemaker notebook no direct internet access"
      identifier           = "SAGEMAKER_NOTEBOOK_NO_DIRECT_INTERNET_ACCESS"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::SageMaker::NotebookInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-sagemaker-notebook-no-direct-internet-access-medium"
        },
      )
      enabled = true
    },
    "sagemaker-notebook-instance-kms-key-configured-medium" = {
      description          = "Managed rule for sagemaker notebook instance kms key configured"
      identifier           = "SAGEMAKER_NOTEBOOK_INSTANCE_KMS_KEY_CONFIGURED"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::SageMaker::NotebookInstance"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-sagemaker-notebook-instance-kms-key-configured-medium"
        },
      )
      enabled = true
    },
    "vpc-default-security-group-closed-medium" = {
      description          = "Managed rule for vpc default security group closed"
      identifier           = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::SecurityGroup"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-vpc-default-security-group-closed-medium"
        },
      )
      enabled = true
    },
    "vpc-flow-logs-enabled-medium" = {
      description          = "Managed rule for vpc flow logs enabled"
      identifier           = "VPC_FLOW_LOGS_ENABLED"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::VPC"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-vpc-flow-logs-enabled-medium"
        },
      )
      enabled = true
    },
    "wafv2-logging-enabled-high" = {
      description          = "Managed rule for wafv2 logging enabled"
      identifier           = "WAFV2_LOGGING_ENABLED"
      trigger_type         = "PERIODIC"
      input_parameters     = {}
      scope_resource_types = ["AWS::WAFv2::WebACL"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-wafv2-logging-enabled-high"
        },
      )
      enabled = true
    },
    "wafv2-webacl-not-empty-high" = {
      description          = "Managed rule for wafv2 webacl not empty"
      identifier           = "WAFV2_WEBACL_NOT_EMPTY"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::WAFv2::WebACL"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-wafv2-webacl-not-empty-high"
        },
      )
      enabled = true
    },
    "waf-regional-webacl-not-empty-high" = {
      description          = "Managed rule for waf regional webacl not empty"
      identifier           = "WAF_REGIONAL_WEBACL_NOT_EMPTY"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::WAFRegional::WebACL"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-waf-regional-webacl-not-empty-high"
        },
      )
      enabled = true
    },
    "elb-logging-enabled-high" = {
      description      = "Managed rule for elb logging enabled"
      identifier       = "ELB_LOGGING_ENABLED"
      trigger_type     = "CONFIGURATION_CHANGE"
      input_parameters = {}
      scope_resource_types = [
        "AWS::ElasticLoadBalancingV2::LoadBalancer",
        "AWS::ElasticLoadBalancing::LoadBalancer"
      ]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-elb-logging-enabled-high"
        },
      )
      enabled = true
    },
    "s3-bucket-server-side-encryption-enabled-high" = {
      description          = "Managed rule for s3 bucket server side encryption enabled"
      identifier           = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::S3::Bucket"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-s3-bucket-server-side-encryption-enabled-high"
        },
      )
      enabled = true
    },
    "s3-account-level-public-access-blocks-high" = {
      description          = "Managed rule for s3 account level public access blocks"
      identifier           = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::S3::AccountPublicAccessBlock"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-s3-account-level-public-access-blocks-high"
        },
      )
      enabled = true
    },
    "s3-bucket-public-write-prohibited-high" = {
      description          = "Managed rule for s3 bucket public write prohibited"
      identifier           = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
      trigger_type         = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters     = {}
      scope_resource_types = ["AWS::S3::Bucket"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-s3-bucket-public-write-prohibited-high"
        },
      )
      enabled = true
    },
    "s3-bucket-public-read-prohibited-high" = {
      description          = "Managed rule for s3 bucket public read prohibited"
      identifier           = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
      trigger_type         = ["CONFIGURATION_CHANGE", "PERIODIC"]
      input_parameters     = {}
      scope_resource_types = ["AWS::S3::Bucket"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-s3-bucket-public-read-prohibited-high"
        },
      )
      enabled = true
    },
    "s3-bucket-acl-prohibited-high" = {
      description          = "Managed rule for s3 bucket acl prohibited"
      identifier           = "S3_BUCKET_ACL_PROHIBITED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::S3::Bucket"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-s3-bucket-acl-prohibited-high"
        },
      )
      enabled = true
    },
    "encrypted-volumes-medium" = {
      description          = "Managed rule for ebs volume prohibited"
      identifier           = "ENCRYPTED_VOLUMES"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::EC2::Volume"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-encrypted-volumes-medium"
        },
      )
      enabled = true
    },
    "rds-cluster-multi-az-enabled-low" = {
      description          = "Managed rule for Amazon Aurora and Multi-AZ DB clusters managed by Amazon RDS"
      identifier           = "RDS_CLUSTER_MULTI_AZ_ENABLED"
      trigger_type         = "CONFIGURATION_CHANGE"
      input_parameters     = {}
      scope_resource_types = ["AWS::RDS::DBCluster"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-rds-cluster-multi-az-enabled-low"
        },
      )
      enabled = true
    },
    "elbv2-predefined-security-policy-ssl-check-low" = {
      description  = "Managed rule to check ELBv2 listeners use predefined security policies"
      identifier   = "ELBV2_PREDEFINED_SECURITY_POLICY_SSL_CHECK"
      trigger_type = "CONFIGURATION_CHANGE"
      input_parameters = {
        sslPolicies = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      }
      scope_resource_types = ["AWS::ElasticLoadBalancingV2::Listener"]
      tags = merge(
        local.tags,
        {
          "Name" = "cfr-${var.service}-${var.environment}-elbv2-predefined-security-policy-ssl-check-low"
        },
      )
      enabled = true
    }
  }
  # # 커스텀 Config 룰 생성
  # {
  #   for lambda_item in var.config_lambda_names_policys : lambda_item[0] => {
  #     owner                = "CUSTOM_LAMBDA"
  #     description          = "Custom config rule for ${lambda_item[0]}"
  #     identifier           = lambda_item[0]
  #     lambda_function_arn  = module.lambda_function[lambda_item[0]].lambda_function_arn
  #     trigger_type         = join(",", lambda_item[2])
  #     resource_types_scope = lambda_item[3]
  #     input_parameters     = lambda_item[4]

  #     //maximum_execution_frequency = contains(lambda_item[2], "PERIODIC") ? "TwentyFour_Hours" : null

  #     tags = merge(
  #       local.tags,
  #       {
  #         "Name" = "cfr-${var.service}-${var.environment}-${lambda_item[0]}"
  #       }
  #     )
  #     enabled = true
  #   }
  # }
}

################################################################################
# Custom Config Rules (Lambda 기반)
################################################################################

resource "aws_config_config_rule" "custom" {
  for_each = {
    for lambda_item in var.config_lambda_names_policys : lambda_item[0] => {
      actions              = lambda_item[1]
      trigger_types        = lambda_item[2]
      resource_types_scope = lambda_item[3]
      input_parameters     = lambda_item[4]
      serverity            = lambda_item[5]
    }
  }

  # name        = each.key
  name        = "${each.key}-${each.value.serverity}"
  description = "Custom config rule for ${each.key}"

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = module.lambda_function[each.key].lambda_function_arn

    source_detail {
      event_source                = "aws.config"
      message_type                = contains(each.value.trigger_types, "CONFIGURATION_CHANGE") ? "ConfigurationItemChangeNotification" : "ScheduledNotification"
      maximum_execution_frequency = contains(each.value.trigger_types, "PERIODIC") ? "TwentyFour_Hours" : null
    }
  }

  dynamic "scope" {
    for_each = length(each.value.resource_types_scope) > 0 ? [1] : []

    content {
      compliance_resource_types = each.value.resource_types_scope
    }
  }

  input_parameters = length(each.value.input_parameters) > 0 ? jsonencode(each.value.input_parameters) : null

  tags = merge(
    local.tags,
    {
      "Name" = "cfr-${var.service}-${var.environment}-${each.key}"
    }
  )
}
