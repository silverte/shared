data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["vpc-${var.service}-${var.environment}"]
  }
}

data "aws_subnets" "app_node" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*app*node*"] # app subnet에 대한 태그 패턴
  }
}

data "aws_subnets" "app_vm_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*app*vm*a*"] # app-a subnet에 대한 태그 패턴
  }
}

data "aws_subnets" "app_vm_c" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*app*vm*c*"] # app-c subnet에 대한 태그 패턴
  }
}

data "aws_subnets" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*db*"] # database subnet에 대한 태그 패턴
  }
}

data "aws_subnets" "elb" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*elb*"] # database subnet에 대한 태그 패턴
  }
}

data "aws_subnets" "endpoint" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*ep*"] # database subnet에 대한 태그 패턴
  }
}

# management에서 생성된 KMS 키의 ARN 또는 동일 계정에서 생성한 Alias를 사용하여 Data Source를 정의
data "aws_kms_key" "ebs" {
  key_id = var.management_ebs_kms_key_arn
}
data "aws_kms_key" "rds" {
  key_id = var.management_rds_kms_key_arn
}

# config 기록을 적재하기 위한 S3
data "aws_s3_bucket" "config" {
  bucket = var.config_s3_bucket_name
}
