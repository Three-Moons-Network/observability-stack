variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name for tagging and naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# ---------------------------------------------------------------------------
# SNS Routing Configuration
# ---------------------------------------------------------------------------

variable "warning_email_addresses" {
  description = "Email addresses for warning-level alerts"
  type        = list(string)
}

variable "warning_phone_numbers" {
  description = "Phone numbers for warning SMS alerts (E.164 format)"
  type        = list(string)
  default     = []
}

variable "enable_warning_sms" {
  description = "Enable SMS for warning-level alerts"
  type        = bool
  default     = false
}

variable "critical_email_addresses" {
  description = "Email addresses for critical-level alerts"
  type        = list(string)
}

variable "critical_phone_numbers" {
  description = "Phone numbers for critical SMS alerts (E.164 format)"
  type        = list(string)
  default     = []
}

variable "enable_slack" {
  description = "Enable Slack integration"
  type        = bool
  default     = false
}

variable "slack_webhook_url" {
  description = "Slack incoming webhook URL"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_pagerduty" {
  description = "Enable PagerDuty integration"
  type        = bool
  default     = false
}

variable "pagerduty_webhook_url" {
  description = "PagerDuty webhook URL"
  type        = string
  default     = ""
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Alarm Thresholds
# ---------------------------------------------------------------------------

variable "enable_lambda_alarms" {
  description = "Enable Lambda alarms"
  type        = bool
  default     = true
}

variable "lambda_error_threshold" {
  description = "Lambda error threshold per 5 minutes (dev=5, prod=1)"
  type        = number
  default     = 5
}

variable "lambda_duration_threshold_ms" {
  description = "Lambda p99 duration threshold in ms (dev=30000, prod=5000)"
  type        = number
  default     = 30000
}

variable "enable_api_gateway_alarms" {
  description = "Enable API Gateway alarms"
  type        = bool
  default     = true
}

variable "api_gateway_5xx_threshold" {
  description = "API Gateway 5xx threshold per 5 minutes (dev=5, prod=1)"
  type        = number
  default     = 5
}

variable "api_gateway_latency_threshold_ms" {
  description = "API Gateway p99 latency threshold in ms (dev=10000, prod=2000)"
  type        = number
  default     = 10000
}

variable "enable_dynamodb_alarms" {
  description = "Enable DynamoDB alarms"
  type        = bool
  default     = true
}

variable "dynamodb_error_threshold" {
  description = "DynamoDB user error threshold per 5 minutes (dev=10, prod=1)"
  type        = number
  default     = 10
}

# ---------------------------------------------------------------------------
# Dashboard Configuration
# ---------------------------------------------------------------------------

variable "dashboard_metric_period" {
  description = "Dashboard metric aggregation period in seconds (60, 300, 3600)"
  type        = number
  default     = 300
}

variable "enable_lambda_metrics" {
  description = "Include Lambda metrics in dashboard"
  type        = bool
  default     = true
}

variable "enable_api_gateway_metrics" {
  description = "Include API Gateway metrics in dashboard"
  type        = bool
  default     = true
}

variable "enable_dynamodb_metrics" {
  description = "Include DynamoDB metrics in dashboard"
  type        = bool
  default     = true
}

variable "enable_s3_metrics" {
  description = "Include S3 metrics in dashboard"
  type        = bool
  default     = true
}

variable "create_log_group" {
  description = "Create CloudWatch log group for Lambda logs"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}
