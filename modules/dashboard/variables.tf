variable "project" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "dashboard_metric_period" {
  description = "Period in seconds for dashboard metrics (60, 300, 3600)"
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
  description = "Create default CloudWatch log group for Lambda"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}
