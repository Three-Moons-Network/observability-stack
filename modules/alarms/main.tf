###############################################################################
# Alarms Module — CloudWatch Alarms
#
# Standard alarm patterns for Lambda, API Gateway, and DynamoDB.
# Thresholds are configurable by environment (dev relaxed, prod tight).
###############################################################################

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# Lambda Alarms
# ---------------------------------------------------------------------------

# Lambda error rate
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = var.enable_lambda_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  alarm_description   = "Lambda error count exceeds ${var.lambda_error_threshold} in 5 minutes"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# Lambda duration (p99 latency)
resource "aws_cloudwatch_metric_alarm" "lambda_duration_p99" {
  count               = var.enable_lambda_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-duration-p99-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  extended_statistic  = "p99"
  threshold           = var.lambda_duration_threshold_ms
  alarm_description   = "Lambda p99 duration exceeds ${var.lambda_duration_threshold_ms}ms"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# Lambda concurrent execution throttles
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count               = var.enable_lambda_alarms ? 1 : 0
  alarm_name          = "${var.project}-lambda-throttles-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function is being throttled"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# API Gateway Alarms
# ---------------------------------------------------------------------------

# API Gateway 5xx errors
resource "aws_cloudwatch_metric_alarm" "api_gateway_5xx" {
  count               = var.enable_api_gateway_alarms ? 1 : 0
  alarm_name          = "${var.project}-api-5xx-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = var.api_gateway_5xx_threshold
  alarm_description   = "API Gateway 5xx errors exceed ${var.api_gateway_5xx_threshold} in 5 minutes"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# API Gateway latency (p99)
resource "aws_cloudwatch_metric_alarm" "api_gateway_latency_p99" {
  count               = var.enable_api_gateway_alarms ? 1 : 0
  alarm_name          = "${var.project}-api-latency-p99-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  extended_statistic  = "p99"
  threshold           = var.api_gateway_latency_threshold_ms
  alarm_description   = "API Gateway p99 latency exceeds ${var.api_gateway_latency_threshold_ms}ms"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# DynamoDB Alarms
# ---------------------------------------------------------------------------

# DynamoDB read throttle events
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttles" {
  count               = var.enable_dynamodb_alarms ? 1 : 0
  alarm_name          = "${var.project}-dynamodb-read-throttles-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DynamoDB read throttle events detected"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# DynamoDB write throttle events
resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttles" {
  count               = var.enable_dynamodb_alarms ? 1 : 0
  alarm_name          = "${var.project}-dynamodb-write-throttles-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DynamoDB write throttle events detected"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# DynamoDB user errors (e.g., validation errors)
resource "aws_cloudwatch_metric_alarm" "dynamodb_user_errors" {
  count               = var.enable_dynamodb_alarms ? 1 : 0
  alarm_name          = "${var.project}-dynamodb-user-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_error_threshold
  alarm_description   = "DynamoDB user errors exceed ${var.dynamodb_error_threshold} in 5 minutes"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}

# DynamoDB system errors (transient service issues)
resource "aws_cloudwatch_metric_alarm" "dynamodb_system_errors" {
  count               = var.enable_dynamodb_alarms ? 1 : 0
  alarm_name          = "${var.project}-dynamodb-system-errors-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "DynamoDB system errors detected"
  alarm_actions       = var.alarm_sns_topic_arns
  treat_missing_data  = "notBreaching"

  tags = local.common_tags
}
