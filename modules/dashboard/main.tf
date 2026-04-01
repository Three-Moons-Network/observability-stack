###############################################################################
# CloudWatch Dashboard Module
#
# Configurable multi-service dashboard for Lambda, API Gateway, DynamoDB,
# and S3. Auto-aggregates metrics and creates meaningful visualizations.
###############################################################################

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${var.project}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = concat(
      local.lambda_widgets,
      local.api_gateway_widgets,
      local.dynamodb_widgets,
      local.s3_widgets,
      local.summary_widgets
    )
  })
}

# ---------------------------------------------------------------------------
# Widget Groups — Modular composition
# ---------------------------------------------------------------------------

# Lambda widgets (invocations, errors, duration, concurrent executions)
locals {
  lambda_widgets = var.enable_lambda_metrics ? [
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/Lambda", "Invocations", { stat = "Sum" }],
          [".", "Errors", { stat = "Sum" }],
          [".", "Duration", { stat = "Average" }],
          [".", "ConcurrentExecutions", { stat = "Maximum" }],
          [".", "Throttles", { stat = "Sum" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Average"
        region = data.aws_region.current.name
        title  = "Lambda Metrics"
        yAxis = {
          left = {
            min = 0
          }
        }
      }
    },
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/Lambda", "Duration", { stat = "p50" }],
          ["...", { stat = "p90" }],
          ["...", { stat = "p99" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Average"
        region = data.aws_region.current.name
        title  = "Lambda Duration Percentiles (ms)"
      }
    },
    {
      type = "log"
      properties = {
        query   = "fields @timestamp, @message, @duration | stats avg(@duration) by bin(5m)"
        region  = data.aws_region.current.name
        title   = "Cold Start Detection"
      }
    },
  ] : []

  # API Gateway widgets (request count, latency, errors, throttles)
  api_gateway_widgets = var.enable_api_gateway_metrics ? [
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/ApiGateway", "Count", { stat = "Sum" }],
          [".", "4XXError", { stat = "Sum" }],
          [".", "5XXError", { stat = "Sum" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Sum"
        region = data.aws_region.current.name
        title  = "API Gateway Requests & Errors"
      }
    },
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/ApiGateway", "Latency", { stat = "Average" }],
          ["...", { stat = "p50" }],
          ["...", { stat = "p99" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Average"
        region = data.aws_region.current.name
        title  = "API Gateway Latency (ms)"
      }
    },
  ] : []

  # DynamoDB widgets (read/write capacity, errors, throttles)
  dynamodb_widgets = var.enable_dynamodb_metrics ? [
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/DynamoDB", "ConsumedReadCapacityUnits", { stat = "Sum" }],
          [".", "ConsumedWriteCapacityUnits", { stat = "Sum" }],
          [".", "UserErrors", { stat = "Sum" }],
          [".", "SystemErrors", { stat = "Sum" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Sum"
        region = data.aws_region.current.name
        title  = "DynamoDB Capacity & Errors"
      }
    },
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/DynamoDB", "ReadThrottleEvents", { stat = "Sum" }],
          [".", "WriteThrottleEvents", { stat = "Sum" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Sum"
        region = data.aws_region.current.name
        title  = "DynamoDB Throttle Events"
      }
    },
  ] : []

  # S3 widgets (request count, 4xx/5xx errors)
  s3_widgets = var.enable_s3_metrics ? [
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/S3", "NumberOfObjects", { stat = "Average" }],
          [".", "BucketSizeBytes", { stat = "Average" }],
          [".", "AllRequests", { stat = "Sum" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Average"
        region = data.aws_region.current.name
        title  = "S3 Bucket Metrics"
      }
    },
  ] : []

  # Summary widget (overview of errors across all services)
  summary_widgets = [
    {
      type = "metric"
      properties = {
        metrics = [
          ["AWS/Lambda", "Errors", { stat = "Sum", label = "Lambda Errors" }],
          ["AWS/ApiGateway", "5XXError", { stat = "Sum", label = "API 5XX" }],
          ["AWS/DynamoDB", "UserErrors", { stat = "Sum", label = "DynamoDB Errors" }],
        ]
        period = var.dashboard_metric_period
        stat   = "Sum"
        region = data.aws_region.current.name
        title  = "Error Rate Overview (5-min sum)"
        yAxis = {
          left = {
            min = 0
          }
        }
      }
    },
  ]
}

data "aws_region" "current" {}

# ---------------------------------------------------------------------------
# CloudWatch Log Group (for Logs Insights queries)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "application" {
  count             = var.create_log_group ? 1 : 0
  name              = "/aws/lambda/${var.project}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-logs-${var.environment}"
    }
  )
}
