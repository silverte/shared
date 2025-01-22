################################################################################
# EC2 Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
################################################################################
module "ec2_sms" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_sms

  name = "ec2-${var.service}-${var.environment}-sms"

  //ami                         = data.aws_ami.ec2_ami.id
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_sms_instance_type
  availability_zone           = element(local.azs, 0)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_sms.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_sms_private_ip

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
      volume_size = var.ec2_sms_ebs_volume_size
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

module "ec2_nexus" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_nexus

  name = "ec2-${var.service}-${var.environment}-nexus"

  #ami               = data.aws_ami.ec2_ami.id
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_nexus_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_nexus.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_nexus_private_ip

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
          "Name" = "ebs-${var.service}-${var.environment}-nexus-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_nexus_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-nexus-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-nexus"
    },
  )
}

module "ec2_whatap" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_whatap

  name = "ec2-${var.service}-${var.environment}-whatap"

  ami               = var.ec2_ami_id
  instance_type     = var.ec2_whatap_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_whatap.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_whatap_private_ip

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
          "Name" = "ebs-${var.service}-${var.environment}-whatap-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_whatap_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-whatap-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-whatap"
    },
  )
}
