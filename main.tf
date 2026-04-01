###############################################################################
# observability-stack
#
# Reusable CloudWatch observability stack: dashboards, alarms, SNS routing,
# and Logs Insights queries for Lambda, API Gateway, DynamoDB workloads.
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# SNS Topic Routing (warnings and critical)
# ---------------------------------------------------------------------------

module "sns_routing" {
  source = "./modules/sns-routing"

  project                   = var.project
  environment               = var.environment
  warning_email_addresses   = var.warning_email_addresses
  warning_phone_numbers     = var.warning_phone_numbers
  enable_warning_sms        = var.enable_warning_sms
  critical_email_addresses  = var.critical_email_addresses
  critical_phone_numbers    = var.critical_phone_numbers
  enable_slack              = var.enable_slack
  slack_webhook_url         = var.slack_webhook_url
  enable_pagerduty          = var.enable_pagerduty
  pagerduty_webhook_url     = var.pagerduty_webhook_url
}

# ---------------------------------------------------------------------------
# CloudWatch Alarms
# ---------------------------------------------------------------------------

module "alarms" {
  source = "./modules/alarms"

  project                            = var.project
  environment                        = var.environment
  alarm_sns_topic_arns               = [module.sns_routing.critical_topic_arn]
  enable_lambda_alarms               = var.enable_lambda_alarms
  lambda_error_threshold             = var.lambda_error_threshold
  lambda_duration_threshold_ms       = var.lambda_duration_threshold_ms
  enable_api_gateway_alarms          = var.enable_api_gateway_alarms
  api_gateway_5xx_threshold          = var.api_gateway_5xx_threshold
  api_gateway_latency_threshold_ms   = var.api_gateway_latency_threshold_ms
  enable_dynamodb_alarms             = var.enable_dynamodb_alarms
  dynamodb_error_threshold           = var.dynamodb_error_threshold
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard
# ---------------------------------------------------------------------------

module "dashboard" {
  source = "./modules/dashboard"

  project                      = var.project
  environment                  = var.environment
  dashboard_metric_period      = var.dashboard_metric_period
  enable_lambda_metrics        = var.enable_lambda_metrics
  enable_api_gateway_metrics   = var.enable_api_gateway_metrics
  enable_dynamodb_metrics      = var.enable_dynamodb_metrics
  enable_s3_metrics            = var.enable_s3_metrics
  create_log_group             = var.create_log_group
  log_retention_days           = var.log_retention_days
}

# ---------------------------------------------------------------------------
# CloudWatch Logs Insights Queries
# ---------------------------------------------------------------------------

module "log_insights" {
  source = "./modules/log-insights"

  project            = var.project
  environment        = var.environment
  create_log_group   = false  # Reuse log group from dashboard module
  log_retention_days = var.log_retention_days
}
