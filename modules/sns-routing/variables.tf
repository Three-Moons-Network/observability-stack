variable "project" {
  description = "Project name for naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# ---------------------------------------------------------------------------
# Warning Subscriptions
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

# ---------------------------------------------------------------------------
# Critical Subscriptions
# ---------------------------------------------------------------------------

variable "critical_email_addresses" {
  description = "Email addresses for critical-level alerts"
  type        = list(string)
}

variable "critical_phone_numbers" {
  description = "Phone numbers for critical SMS alerts (E.164 format)"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# Integration Services
# ---------------------------------------------------------------------------

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
  description = "Enable PagerDuty integration for critical alerts"
  type        = bool
  default     = false
}

variable "pagerduty_webhook_url" {
  description = "PagerDuty webhook URL for integration events"
  type        = string
  default     = ""
  sensitive   = true
}
