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


#####################################################################################
# IAM policy for container app
#####################################################################################
module "iam_policy_container_app" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_iam_policy

  name        = "policy-${var.service}-${var.environment}-container-app-default"
  path        = "/"
  description = "IAM policy for container app"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-contents/*",
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-files/*"
			]
		},
		{
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": [
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-contents",
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-files"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"sqs:SendMessage",
				"sqs:ReceiveMessage",
				"sqs:DeleteMessage",
				"sqs:GetQueueAttributes",
				"sqs:GetQueueUrl"
			],
			"Resource": "arn:aws:sqs:ap-northeast-2:${var.accounts["shared"]}:sqs-${var.service}-${var.environment}-app.fifo"
		}
	]
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-container-app-default"
    },
  )
}

#####################################################################################
# IAM policy for vm app
#####################################################################################
module "iam_policy_vm_app" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_iam_policy

  name        = "policy-${var.service}-${var.environment}-vm-app-default"
  path        = "/"
  description = "IAM policy for vm app"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": [
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-contents/*",
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-files/*"
			]
		},
		{
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": [
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-contents",
				"arn:aws:s3:::s3-${var.service}-${var.environment}-cm-files"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"sqs:SendMessage",
				"sqs:ReceiveMessage",
				"sqs:DeleteMessage",
				"sqs:GetQueueAttributes",
				"sqs:GetQueueUrl"
			],
			"Resource": "arn:aws:sqs:ap-northeast-2:${var.accounts["shared"]}:sqs-${var.service}-${var.environment}-app.fifo"
		}
	]
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-vm-app-default"
    },
  )
}

#####################################################################################
# IAM policy for vm app initial
#####################################################################################
module "iam_policy_vm_app_initial" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  create_policy = var.create_iam_policy

  name        = "policy-${var.service}-${var.environment}-vm-app-default-initial"
  path        = "/"
  description = "IAM policy for vm app initial"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetObject",
				"s3:PutObject",
				"s3:DeleteObject"
			],
			"Resource": [
        "arn:aws:s3:::s3-esp-shared-infra-utils/*",
        "arn:aws:s3:::s3-esp-shared-deploy-keys/*"
			]
		},
		{
			"Effect": "Allow",
			"Action": "s3:ListBucket",
			"Resource": [
        "arn:aws:s3:::s3-esp-shared-infra-utils",
        "arn:aws:s3:::s3-esp-shared-deploy-keys"
			]
		}
	]
}
EOF

  tags = merge(
    local.tags,
    {
      Name = "policy-${var.service}-${var.environment}-vm-app-default-initial"
    },
  )
}
