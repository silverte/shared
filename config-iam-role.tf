##########################################################################
# IAM Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-iam
##########################################################################

#################################################################################
# IAM role for Config
#################################################################################
resource "aws_iam_role" "config" {
  count = !(var.create_config_ap_northeast-2 || var.create_config_us_east_1) ? 0 : 1
  name  = "role-${var.service}-${var.environment}-config"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(
    local.tags,
    {
      Name = "role-${var.service}-${var.environment}-config"
    },
  )
}

resource "aws_iam_role_policy_attachment" "attach_access_config_bucket" {
  count      = length(aws_iam_role.config) == 0 ? 0 : 1
  role       = aws_iam_role.config[0].name
  policy_arn = module.iam_policy_access_config_bucket.arn
}

resource "aws_iam_role_policy_attachment" "attach_config_basic_policy" {
  count      = length(aws_iam_role.config) == 0 ? 0 : 1
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy_attachment" "attach_invoke_lambda" {
  count      = length(aws_iam_role.config) == 0 ? 0 : 1
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}
