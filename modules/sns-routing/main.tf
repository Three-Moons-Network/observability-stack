###############################################################################
# SNS Routing Module — Alert Subscription Management
#
# Routes alarms to email, SMS, Slack, or PagerDuty based on severity.
# Enables severity-based escalation (warning → email, critical → SMS).
###############################################################################

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# SNS Topics by Severity
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "warnings" {
  name              = "${var.project}-warnings-${var.environment}"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-warnings"
    }
  )
}

resource "aws_sns_topic" "critical_alerts" {
  name              = "${var.project}-critical-${var.environment}"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-critical"
    }
  )
}

# Policy to allow CloudWatch to publish
resource "aws_sns_topic_policy" "warnings" {
  arn = aws_sns_topic.warnings.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.warnings.arn
    }]
  })
}

resource "aws_sns_topic_policy" "critical_alerts" {
  arn = aws_sns_topic.critical_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudwatch.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.critical_alerts.arn
    }]
  })
}

# ---------------------------------------------------------------------------
# Subscriptions — Warnings Topic
# ---------------------------------------------------------------------------

# Email subscriptions for warnings
resource "aws_sns_topic_subscription" "warnings_email" {
  for_each = toset(var.warning_email_addresses)

  topic_arn = aws_sns_topic.warnings.arn
  protocol  = "email"
  endpoint  = each.value
}

# SMS for warnings (optional, less aggressive than critical)
resource "aws_sns_topic_subscription" "warnings_sms" {
  for_each = var.enable_warning_sms ? toset(var.warning_phone_numbers) : toset([])

  topic_arn = aws_sns_topic.warnings.arn
  protocol  = "sms"
  endpoint  = each.value
}

# Slack for warnings (optional)
resource "aws_sns_topic_subscription" "warnings_slack" {
  count     = var.enable_slack && var.slack_webhook_url != "" ? 1 : 0
  topic_arn = aws_sns_topic.warnings.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}

# ---------------------------------------------------------------------------
# Subscriptions — Critical Alerts Topic
# ---------------------------------------------------------------------------

# Email for critical (always)
resource "aws_sns_topic_subscription" "critical_email" {
  for_each = toset(var.critical_email_addresses)

  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# SMS for critical (always enabled if phone numbers provided)
resource "aws_sns_topic_subscription" "critical_sms" {
  for_each = toset(var.critical_phone_numbers)

  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "sms"
  endpoint  = each.value
}

# PagerDuty for critical escalation
resource "aws_sns_topic_subscription" "critical_pagerduty" {
  count     = var.enable_pagerduty && var.pagerduty_webhook_url != "" ? 1 : 0
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "https"
  endpoint  = var.pagerduty_webhook_url
}

# Slack for critical (priority over warnings)
resource "aws_sns_topic_subscription" "critical_slack" {
  count     = var.enable_slack && var.slack_webhook_url != "" ? 1 : 0
  topic_arn = aws_sns_topic.critical_alerts.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}

# ---------------------------------------------------------------------------
# Optional: Lambda for Message Transformation
# ---------------------------------------------------------------------------

# Note: If you want to reformat messages (e.g., for Slack), create a Lambda
# and subscribe it to the SNS topic. This module provides the SNS topics;
# the Lambda transformation is a separate concern.
# Example Lambda that transforms CloudWatch alarm messages for Slack:
#
# resource "aws_lambda_function" "slack_formatter" {
#   filename      = "slack-formatter.zip"
#   function_name = "${var.project}-slack-formatter"
#   role          = aws_iam_role.slack_formatter.arn
#   handler       = "index.handler"
#   runtime       = "python3.11"
#
#   environment {
#     variables = {
#       SLACK_WEBHOOK = var.slack_webhook_url
#     }
#   }
# }
#
# resource "aws_sns_topic_subscription" "slack_lambda" {
#   topic_arn = aws_sns_topic.warnings.arn
#   protocol  = "lambda"
#   endpoint  = aws_lambda_function.slack_formatter.arn
# }
