##########################################################################
# IAM Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-iam
##########################################################################

#####################################################################################
# IAM policy for access config bucket
#####################################################################################
module "iam_policy_access_config_bucket" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_config_ap_northeast-2 || var.create_config_us_east_1

  name        = "policy-${var.service}-${var.environment}-access-config-bucket"
  path        = "/"
  description = "IAM policy for access config bucket"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:ListBucket",
				"s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::s3-esp-mgmt-config-log"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::s3-esp-mgmt-config-log/*"
        }
    ]
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-access-config-bucket"
    },
  )
}
