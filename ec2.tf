################################################################################
# EC2 Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
################################################################################
# EC2 AMI
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ec2_ami_filter_value]
  }
}

module "ec2_sms" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_mig_db

  name = "ec2-${var.service}-${var.environment}-sms"

  ami                         = data.aws_ami.ec2_ami.id
  instance_type               = var.ec2_mig_db_instance_type
  availability_zone           = element(local.azs, 0)
  subnet_id                   = data.aws_subnets.app.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_sms.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 8
    instance_metadata_tags      = "enabled"
  }

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      volume_type = "gp3"
      volume_size = var.ec2_root_volume_size
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-sms-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_mig_db_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-sms-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-sms"
    },
  )
}