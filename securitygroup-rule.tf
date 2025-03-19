#####################################################################################
#  permanent
#####################################################################################
# Security Group 룰 추가 (변수가 true일 때)
resource "null_resource" "add_sg_rules_permanent" {
  count = var.create_security_group_rule_permanent ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
#!/bin/bash
SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'response_development')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Adding rules to Security Group: $SG_ID"
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"PrefixListIds":[{"PrefixListId":"pl-0afad9bada0b816bb", "Description":"Shared AMDP deploy"}]}
  ]' 2>/dev/null || echo "Ingress rules may already exist for $SG_ID"
done

SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'ec2')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Adding rules to Security Group: $SG_ID"
  aws ec2 authorize-security-group-egress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":443,"ToPort":443,"UserIdGroupPairs":[{"GroupId":"sg-0348dcd4561b8bb44", "Description":"VPC Endpoint-interface"}]},
    {"IpProtocol":"tcp","FromPort":6600,"ToPort":6600,"UserIdGroupPairs":[{"GroupId":"sg-0b3af75318d98c45c", "Description":"Shared whatap server"}]},
    {"IpProtocol":"tcp","FromPort":443,"ToPort":443,"PrefixListIds":[{"PrefixListId":"pl-78a54011", "Description":"VPC Endpoint-gateway"}]}
  ]' 2>/dev/null || echo "Egress rules already exist for $SG_ID"
done

EOF

    interpreter = ["/bin/bash", "-c"]
  }

  # lifecycle {
  #   ignore_changes = [triggers]
  # }
}

# Security Group 룰 삭제 (변수가 false일 때)
resource "null_resource" "remove_sg_rules_permanent" {
  count = var.create_security_group_rule_permanent ? 0 : 1

  provisioner "local-exec" {
    command     = <<EOF
#!/bin/bash
SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'response_development')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Removing rules to Security Group: $SG_ID"
  aws ec2 revoke-security-group-ingress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"PrefixListIds":[{"PrefixListId":"pl-0afad9bada0b816bb"}]}
  ]' 2>/dev/null || echo "Ingress rules may already exist for $SG_ID"
done

SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'ec2')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Removing rules from Security Group: $SG_ID"
  aws ec2 revoke-security-group-egress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":443,"ToPort":443,"UserIdGroupPairs":[{"GroupId":"sg-0348dcd4561b8bb44"}]},
    {"IpProtocol":"tcp","FromPort":6600,"ToPort":6600,"UserIdGroupPairs":[{"GroupId":"sg-0b3af75318d98c45c"}]},
    {"IpProtocol":"tcp","FromPort":443,"ToPort":443,"PrefixListIds":[{"PrefixListId":"pl-78a54011"}]}
  ]' 2>/dev/null || echo "Egress rules already removed for $SG_ID"
done

EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

#####################################################################################
#  temporary
#####################################################################################
# Security Group 룰 추가 (변수가 true일 때)
resource "null_resource" "add_sg_rules_temporary" {
  count = var.create_security_group_rule_temporary ? 1 : 0

  provisioner "local-exec" {
    command     = <<EOF
#!/bin/bash
SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'ec2')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Adding rules to Security Group: $SG_ID"
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"UserIdGroupPairs":[{"GroupId":"sg-0f2bc68c4bca4202e", "Description":"Shared admin server"}]},
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"PrefixListIds":[{"PrefixListId":"pl-05f5d1bfbb8cde8f0","Description":"Security bastion server"}]}
  ]' || echo "Ingress rules may already exist for $SG_ID"
done

EOF
    interpreter = ["/bin/bash", "-c"]
  }
}

# Security Group 룰 삭제 (변수가 false일 때)
resource "null_resource" "remove_sg_rules_temporary" {
  count = var.create_security_group_rule_temporary ? 0 : 1

  provisioner "local-exec" {
    command     = <<EOF
#!/bin/bash
SG_IDS=$(aws ec2 describe-security-groups \
  --query "SecurityGroups[?contains(GroupName, 'ec2')].GroupId" \
  --output text)

for SG_ID in $SG_IDS; do
  echo "Removing rules from Security Group: $SG_ID"
  aws ec2 revoke-security-group-ingress --group-id $SG_ID --ip-permissions '[
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"UserIdGroupPairs":[{"GroupId":"sg-0f2bc68c4bca4202e"}]},
    {"IpProtocol":"tcp","FromPort":22,"ToPort":22,"PrefixListIds":[{"PrefixListId":"pl-05f5d1bfbb8cde8f0"}]}
  ]' || echo "Ingress rules already removed or not present for $SG_ID"
done

EOF
    interpreter = ["/bin/bash", "-c"]
  }

  # lifecycle {
  #   ignore_changes = [triggers]
  # }
}
