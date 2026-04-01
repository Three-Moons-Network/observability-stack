# Remote state backend configuration (optional)
# For team environments, uncomment and configure for S3 + DynamoDB locking

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "observability-stack/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
