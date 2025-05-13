
################################################################################
# Lambda Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-lambda
################################################################################

locals {
  config_lambda_roles = {
    for lambda_item in var.config_lambda_names_policys :
    lambda_item[0] => {
      actions = lambda_item[1]
    }
  }
}

module "lambda_function" {
  source      = "terraform-aws-modules/lambda/aws"
  create      = var.create_config_lambda
  description = "for Config Custom Rule"

  for_each      = local.config_lambda_roles
  function_name = "lamdba-${var.service}-${var.environment}-config-${each.key}"
  handler       = "${each.key}.lambda_handler"
  runtime       = "python3.13"
  source_path   = "lambda/config/${each.key}.py"
  timeout       = 60

  create_role = true
  role_name   = "role-${var.service}-${var.environment}-lambda-${each.key}"

  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = each.value.actions,
      Resource = "*"
    }]
  })

  # attach_policy_arns = true
  # policy_arns = [
  #   "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole",
  #   "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  # ]
  tags = merge(
    local.tags,
    {
      Name = "lamdba-${var.service}-${var.environment}-config-${each.key}"
    },
  )
}

resource "aws_iam_role_policy_attachment" "lambda_config_execution" {
  for_each = local.config_lambda_roles

  role       = "role-${var.service}-${var.environment}-lambda-${each.key}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole"

  depends_on = [module.lambda_function]
}

resource "aws_lambda_permission" "allow_config_invoke" {
  for_each = local.config_lambda_roles

  statement_id  = "AllowConfigInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function[each.key].lambda_function_name
  principal     = "config.amazonaws.com"

  depends_on = [module.lambda_function]
}

# AWSLambdaBasicExecutionRole -> 람다 생성시 자동 만들어지는 롤
# AWSConfigRulesExecutionRole -> 왠지 config 연결시 자동으로 만들어지는 롤 같음...


# inline  (앞에 2개는 기본)

# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "logs:*",
#                 "config:PutEvaluations",
#                 "ec2:DescribeSecurityGroups"
#             ],
#             "Resource": "*",
#             "Effect": "Allow"
#         }
#     ]
# }
