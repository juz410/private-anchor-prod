locals {
  function_name = coalesce(
    var.function_name,
    substr("${var.resource_name_prefix}-sns-publisher", 0, 64),
  )
}

data "archive_file" "package" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.py"
  output_path = "${path.module}/lambda_sns_publisher.zip"
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.function_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = ["sns:Publish"]
    resources = values(var.topic_map)
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${local.function_name}-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_lambda_function" "this" {
  function_name    = local.function_name
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  filename         = data.archive_file.package.output_path
  source_code_hash = data.archive_file.package.output_base64sha256
  timeout          = var.lambda_timeout_seconds
  memory_size      = var.lambda_memory_mb

  environment {
    variables = merge(
      {
        SNS_TOPIC_MAP            = jsonencode(var.topic_map)
        AWSBACKUP_STATE_TOPIC_MAPPING      = jsonencode(var.awsbackup_state_topic_mapping)
        EC2_STATE_TOPIC_LABEL    = var.ec2_state_topic_label
        EC2_STATE_TOPIC_MAPPING  = jsonencode(var.ec2_state_topic_mapping)
      },
      var.project_id != null ? { PROJECT_ID = var.project_id } : {},
      var.environment != null ? { ENVIRONMENT = var.environment } : {},
      var.subject_template != null ? { SUBJECT_TEMPLATE = var.subject_template } : {},
      var.message_template != null ? { MESSAGE_TEMPLATE = var.message_template } : {},
      var.ec2_subject_template != null ? { EC2_SUBJECT_TEMPLATE = var.ec2_subject_template } : {},
      var.ec2_message_template != null ? { EC2_MESSAGE_TEMPLATE = var.ec2_message_template } : {},
      var.default_topic_label != null ? { DEFAULT_TOPIC_LABEL = var.default_topic_label } : {},
      var.lambda_additional_env,
    )
  }

  tags = var.tags
}
