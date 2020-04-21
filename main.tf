provider "aws" {
  region = "ap-southeast-2"
}

resource "random_id" "bucket_name" {
  prefix = "terraform-aws-lambda-builder-tests-"
  byte_length = 8
}

resource "aws_s3_bucket" "packages" {
  bucket = random_id.bucket_name.hex
  acl = "private"
}

module "lambda_function_downloader" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "downloader"
  handler = "downloader.handler"
  runtime = var.runtime
  s3_bucket = aws_s3_bucket.packages.id
  timeout = 30

  # Enable build functionality.
  build_mode = "LAMBDA"
  source_dir = "${path.module}/downloader"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}

module "lambda_function_persister" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "persister"
  handler = "persister.handler"
  runtime = var.runtime
  s3_bucket = aws_s3_bucket.packages.id
  timeout = 30

  # Enable build functionality.
  build_mode = "LAMBDA"
  source_dir = "${path.module}/persister"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}

output "function_names" {
  value = [
    module.lambda_function_downloader.function_name,
    module.lambda_function_persister.function_name,
  ]
}
