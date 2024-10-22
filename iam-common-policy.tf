#####################################################################################
# IAM policy to restrict ip
#####################################################################################
module "iam_policy_restrict_ip" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_iam_assumeable_role

  name        = "policy-${var.service}-${var.environment}-restrict-ip"
  path        = "/"
  description = "IAM policy to restrict ip"

  policy = <<EOF
{
	"Statement": [
		{
			"Action": "*",
			"Condition": {
				"Bool": {
					"aws:ViaAWSService": "false"
				},
				"NotIpAddress": {
					"aws:SourceIp": [
						"211.45.61.18/32",
						"59.6.169.100/32",
						"211.234.226.89/32",
						"203.251.242.124/32"
					]
				}
			},
			"Effect": "Deny",
			"Resource": "*"
		}
	],
	"Version": "2012-10-17"
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-restrict-ip"
    },
  )
}

#####################################################################################
# IAM policy to restrict region
#####################################################################################
module "iam_policy_restrict_region" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_iam_assumeable_role

  name        = "policy-${var.service}-${var.environment}-restrict-region"
  path        = "/"
  description = "IAM policy to restrict region"

  policy = <<EOF
{
  "Statement": [
      {
          "Action": "*",
          "Condition": {
              "StringNotEquals": {
                  "aws:RequestedRegion": [
                      "ap-northeast-2",
                      "us-east-1"
                  ]
              }
          },
          "Effect": "Deny",
          "Resource": "*"
      },
      {
          "Condition": {
              "StringEquals": {
                  "aws:RequestedRegion": "us-east-1"
              }
          },
          "Effect": "Deny",
          "NotAction": [
              "iam:*",
              "s3:*",
              "cloudfront:*",
              "route53:*",
              "route53domains:*",
              "route53resolver:*",
              "ec2:DescribeVpcs",
              "access-analyzer:*",
              "acm:*",
              "organizations:*"
          ],
          "Resource": "*"
      }
  ],
  "Version": "2012-10-17"
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-restrict-region"
    },
  )
}
