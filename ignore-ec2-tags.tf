resource "null_resource" "ignore_ec2_tags" {
  for_each = {
    # "ec2_ezjobs01" = module.ec2_ezjobs01.id
    # "ec2_ezjobs02"   = module.ec2_ezjobs02.id
    # "ec2_whatap"     = module.ec2_whatap.id
    # "ec2_whatap_stg" = module.ec2_whatap_stg.id
    # "ec2_nexus"      = module.ec2_nexus.id
    # "ec2_metasharp"  = module.ec2_metasharp.id
    # "ec2_sms"        = module.ec2_sms.id
    # "ec2_mig"        = module.ec2_mig.id
  }

  triggers = {
    instance_id = each.value
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ec2 create-tags --resources ${each.value} \
      --tags Key=schedule,Value=ignore Key=InstanceScheduler-LastAction,Value=ignore
    EOT
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}
