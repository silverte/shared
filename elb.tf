module "security_group_eks" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"
  create  = var.create_alb

  name            = "scg-${var.service}-${var.environment}-alb-container"
  use_name_prefix = false
  description     = "Security group for EKS ALB ingress "
  vpc_id          = data.aws_vpc.vpc.id

  # ingress_cidr_blocks = ["0.0.0.0/0"]
  # ingress_rules       = ["https-443-tcp", "all-icmp"]
  # egress_rules = ["all-all"]

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-alb-container"
    },
  )
}

module "alb_vm" {
  source = "terraform-aws-modules/alb/aws"

  name    = "alb-${var.service}-${var.environment}-vm"
  vpc_id  = data.aws_vpc.vpc.id
  subnets = data.aws_subnets.elb.ids

  # Security Group
  security_group_name            = "scg-${var.service}-${var.environment}-alb-vm"
  security_group_use_name_prefix = false
  security_group_description     = "Security group for VM ALB ingress"
  security_group_tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-alb-vm"
    },
  )

  # security_group_ingress_rules = {
  #   all_http = {
  #     from_port   = 80
  #     to_port     = 80
  #     ip_protocol = "tcp"
  #     description = "HTTP web traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  #   all_https = {
  #     from_port   = 443
  #     to_port     = 443
  #     ip_protocol = "tcp"
  #     description = "HTTPS web traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  # }
  # security_group_egress_rules = {
  #   all = {
  #     ip_protocol = "-1"
  #     cidr_ipv4   = "10.0.0.0/16"
  #   }
  # }

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  # listeners = {
  #   ex-http-https-redirect = {
  #     port     = 80
  #     protocol = "HTTP"
  #     redirect = {
  #       port        = "443"
  #       protocol    = "HTTPS"
  #       status_code = "HTTP_301"
  #     }
  #   }
  #   ex-https = {
  #     port            = 443
  #     protocol        = "HTTPS"
  #     certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

  #     forward = {
  #       target_group_key = "ex-instance"
  #     }
  #   }
  # }

  # target_groups = {
  #   ex-instance = {
  #     name_prefix = "h1"
  #     protocol    = "HTTP"
  #     port        = 80
  #     target_type = "instance"
  #     target_id   = "i-0f6d38a07d50d080f"
  #   }
  # }

  tags = merge(
    local.tags,
    {
      "Name" = "scg-${var.service}-${var.environment}-alb-vm"
    },
  )
}
