variable "project" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "alarm_sns_topic_arns" {
  description = "SNS topic ARNs to send alarm notifications to"
  type        = list(string)
}

# ---------------------------------------------------------------------------
# Lambda Alarm Thresholds
# ---------------------------------------------------------------------------

variable "enable_lambda_alarms" {
  description = "Enable Lambda alarms"
  type        = bool
  default     = true
}

variable "lambda_error_threshold" {
  description = "Lambda error count threshold (per 5 minutes)"
  type        = number
  default     = 5 # dev: 5, prod: 1
}

variable "lambda_duration_threshold_ms" {
  description = "Lambda p99 duration threshold in milliseconds"
  type        = number
  default     = 30000 # dev: 30000ms (30s), prod: 5000ms (5s)
}

# ---------------------------------------------------------------------------
# API Gateway Alarm Thresholds
# ---------------------------------------------------------------------------

variable "enable_api_gateway_alarms" {
  description = "Enable API Gateway alarms"
  type        = bool
  default     = true
}

variable "api_gateway_5xx_threshold" {
  description = "API Gateway 5xx error count threshold (per 5 minutes)"
  type        = number
  default     = 5 # dev: 5, prod: 1
}

variable "api_gateway_latency_threshold_ms" {
  description = "API Gateway p99 latency threshold in milliseconds"
  type        = number
  default     = 10000 # dev: 10000ms (10s), prod: 2000ms (2s)
}

# ---------------------------------------------------------------------------
# DynamoDB Alarm Thresholds
# ---------------------------------------------------------------------------

variable "enable_dynamodb_alarms" {
  description = "Enable DynamoDB alarms"
  type        = bool
  default     = true
}

variable "dynamodb_error_threshold" {
  description = "DynamoDB user error count threshold (per 5 minutes)"
  type        = number
  default     = 10 # dev: 10, prod: 1
}
