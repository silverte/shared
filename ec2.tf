################################################################################
# EC2 Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
################################################################################

####################################################
##################### ezjobs01 #####################
####################################################

module "ec2_ezjobs01" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_ezjobs01

  name = "ec2-${var.service}-${var.environment}-ezjobs01"

  ami               = var.ec2_ami_id
  instance_type     = var.ec2_ezjobs01_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_ezjobs.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data_20250311_include_whatap.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_ezjobs01_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
          "Name" = "ebs-${var.service}-${var.environment}-ezjobs01-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_ezjobs01_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-ezjobs01-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-ezjobs01"
    }
  )
}

####################################################
##################### ezjobs02 #####################
####################################################

module "ec2_ezjobs02" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_ezjobs02

  name = "ec2-${var.service}-${var.environment}-ezjobs02"

  ami           = var.ec2_ami_id
  instance_type = var.ec2_ezjobs02_instance_type
  # az_c를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  availability_zone           = element(local.azs, 1)
  subnet_id                   = data.aws_subnets.app_vm_c.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_ezjobs.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data_20250311_include_whatap.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_ezjobs02_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
          "Name" = "ebs-${var.service}-${var.environment}-ezjobs02-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_ezjobs02_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-ezjobs02-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-ezjobs02"
    },
  )
}

##################################################
##################### whatap (dev) ###############
##################################################

module "ec2_whatap" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_whatap_dev

  name = "ec2-${var.service}-${var.environment}-whatap_dev"

  ami               = var.ec2_ami_id
  instance_type     = var.ec2_whatap_dev_instance_type
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
  private_ip                  = var.ec2_whatap_dev_private_ip
  iam_instance_profile        = null

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
          "Name" = "ebs-${var.service}-${var.environment}-whatap_dev-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_whatap_dev_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-whatap_dev-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-whatap_dev"
    },
  )
}

##################################################
##################### whatap (stg) ###############
##################################################

module "ec2_whatap_stg" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_whatap_stg

  name = "ec2-${var.service}-${var.environment}-whatap_stg"

  ami               = var.ec2_ami_id
  instance_type     = var.ec2_whatap_stg_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_whatap_stg.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data_20250311_exclude_whatap.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_whatap_stg_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
          "Name" = "ebs-${var.service}-${var.environment}-whatap_stg-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_whatap_stg_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-whatap_stg-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-whatap_stg"
    },
  )
}

####################################################
####################### nexus ######################
####################################################

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

####################################################
##################### metasharp ####################
####################################################

module "ec2_metasharp" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_metasharp

  name = "ec2-${var.service}-${var.environment}-metasharp"

  #ami               = data.aws_ami.ec2_ami.id
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_metasharp_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_meta.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_metasharp_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
          "Name" = "ebs-${var.service}-${var.environment}-metasharp-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_metasharp_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-metasharp-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-metasharp"
    },
  )
}


####################################################
####################### sms ########################
####################################################

module "ec2_sms" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_sms

  name = "ec2-${var.service}-${var.environment}-sms"

  ami               = var.ec2_ami_id
  instance_type     = var.ec2_sms_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_sms.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data_20250311_include_whatap.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_sms_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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


####################################################
####################### mig ########################
####################################################

module "ec2_mig" {
  source = "terraform-aws-modules/ec2-instance/aws"
  create = var.create_ec2_mig

  name = "ec2-${var.service}-${var.environment}-mig"

  #ami               = data.aws_ami.ec2_ami.id
  ami               = var.ec2_ami_id
  instance_type     = var.ec2_mig_instance_type
  availability_zone = element(local.azs, 0)
  # az_a를 따로 호출 (app subnet이 가용역영별 정렬이 되지 않을 수 있음)
  subnet_id                   = data.aws_subnets.app_vm_a.ids[0]
  vpc_security_group_ids      = [module.security_group_ec2_mig.security_group_id]
  associate_public_ip_address = false
  disable_api_stop            = false
  disable_api_termination     = true
  # https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/hibernating-prerequisites.html#hibernation-prereqs-supported-amis
  hibernation                 = false
  user_data_base64            = base64encode(file("./user_data.sh"))
  user_data_replace_on_change = true
  private_ip                  = var.ec2_mig_private_ip
  iam_instance_profile        = null

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
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
          "Name" = "ebs-${var.service}-${var.environment}-mig-root"
        },
      )
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = var.ec2_mig_ebs_volume_size
      encrypted   = true
      kms_key_id  = data.aws_kms_key.ebs.arn
      tags = merge(
        local.tags,
        {
          "Name" = "ebs-${var.service}-${var.environment}-mig-data01"
        },
      )
    }
  ]

  tags = merge(
    local.tags,
    {
      "Name" = "ec2-${var.service}-${var.environment}-mig"
    },
  )
}
