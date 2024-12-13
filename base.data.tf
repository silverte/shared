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

data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*app*"] # app subnet에 대한 태그 패턴
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
