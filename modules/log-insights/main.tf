###############################################################################
# Log Insights Module — CloudWatch Logs Insights Saved Queries
#
# Pre-built CloudWatch Logs Insights queries for common debugging patterns:
# error rates, cold starts, slow operations, latency percentiles.
###############################################################################

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Note: CloudWatch Logs Insights saved queries are managed via API/CLI
# This module provides the query definitions and documentation for
# how to create and use them.

# Error rate query
locals {
  query_error_rate = <<EOQ
fields @timestamp, @message, @duration, @error
| filter @error like /./
| stats count() as error_count, pct(@duration, 99) as p99_duration by bin(5m)
EOQ

  query_cold_starts = <<EOQ
fields @timestamp, @duration, @initDuration
| filter @initDuration > 0
| stats count() as cold_starts, avg(@duration) as avg_duration, max(@initDuration) as max_init_duration by bin(5m)
EOQ

  query_latency_percentiles = <<EOQ
fields @timestamp, @duration
| stats avg(@duration) as avg_ms, pct(@duration, 50) as p50_ms, pct(@duration, 99) as p99_ms, pct(@duration, 99.9) as p999_ms by bin(1m)
EOQ

  query_slow_requests = <<EOQ
fields @timestamp, @message, @duration, @requestId
| filter @duration > 5000
| sort @duration desc
| limit 100
EOQ

  query_lambda_errors = <<EOQ
fields @timestamp, @message, @error, @errorMessage
| filter @message like /ERROR/
| stats count() as error_count by @errorMessage
| sort error_count desc
EOQ

  query_api_gateway_latency = <<EOQ
fields @timestamp, @duration, @httpMethod, @httpStatus
| stats count() as request_count, avg(@duration) as avg_latency_ms, pct(@duration, 99) as p99_latency_ms by @httpStatus
EOQ

  query_dynamodb_throttles = <<EOQ
fields @timestamp, @message
| filter @message like /throttl/ or @message like /ProvisionedThroughputExceededException/
| stats count() as throttle_count by bin(5m)
EOQ

  query_trace_request = <<EOQ
fields @timestamp, @message, @duration, @requestId
| filter @requestId = ?
| sort @timestamp asc
EOQ
}

# CloudWatch Log Group for storing saved queries
resource "aws_cloudwatch_log_group" "insights" {
  count             = var.create_log_group ? 1 : 0
  name              = "/aws/insights/${var.project}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-insights-${var.environment}"
    }
  )
}

# Outputs the query definitions for manual creation via AWS CLI or Console
# Example AWS CLI usage:
#   aws logs put-query-definition \
#     --name "error-rate-${PROJECT}" \
#     --log-group-name-list "/aws/lambda/${PROJECT}" \
#     --query-string "${QUERY_ERROR_RATE}"

output "query_definitions" {
  description = "CloudWatch Logs Insights query definitions (use with CLI/Console)"
  value = {
    error_rate                = local.query_error_rate
    cold_starts               = local.query_cold_starts
    latency_percentiles       = local.query_latency_percentiles
    slow_requests             = local.query_slow_requests
    lambda_errors             = local.query_lambda_errors
    api_gateway_latency       = local.query_api_gateway_latency
    dynamodb_throttles        = local.query_dynamodb_throttles
    trace_request_by_id       = local.query_trace_request
  }
}

# Query helper documentation
output "query_guide" {
  description = "How to use these Insights queries"
  value = <<EOG
CloudWatch Logs Insights Saved Queries

To create a saved query via AWS CLI:
  aws logs put-query-definition \
    --name "query-name" \
    --log-group-name-list "/aws/lambda/your-function" \
    --query-string "QUERY_STRING"

Common patterns:

1. Error Rate (last 1 hour)
   - Fields: @timestamp, @message, @duration, @error
   - Filter: @error like /./
   - Stats: count() errors by bin(5m)

2. Cold Starts Detection
   - Fields: @timestamp, @duration, @initDuration
   - Filter: @initDuration > 0
   - Stats: count() cold_starts by bin(5m)

3. Latency Percentiles (p50, p99, p999)
   - Fields: @timestamp, @duration
   - Stats: pct(@duration, 50/99/999) by bin(1m)

4. Slow Requests (>5 second duration)
   - Fields: @timestamp, @message, @duration, @requestId
   - Filter: @duration > 5000
   - Sort: @duration desc

5. API Gateway Errors by Status Code
   - Fields: @timestamp, @message, @httpStatus
   - Stats: count() by @httpStatus
   - Filter: @httpStatus >= 500

6. DynamoDB Throttles Detection
   - Fields: @timestamp, @message
   - Filter: @message like /throttl/
   - Stats: count() by bin(5m)

7. Trace Request by ID (for debugging)
   - Fields: @timestamp, @message, @duration, @requestId
   - Filter: @requestId = "REQUEST_ID"
   - Sort: @timestamp asc

Best Practices:
- Use bin(5m) for 5-minute aggregations
- Filter early to reduce scanned data (cost)
- Use pct() for percentile metrics (p50, p99, p99.9)
- Always include @timestamp for time-series analysis
- Combine with CloudWatch metric filters for alerting
EOG
}
