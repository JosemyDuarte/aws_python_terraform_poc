provider "aws" {
  region = "ap-southeast-2"
}

resource "random_id" "packages_bucket_name" {
  prefix = "terraform-aws-lambda-builder-tests-"
  byte_length = 8
}

resource "aws_s3_bucket" "packages" {
  bucket = random_id.packages_bucket_name.hex
  force_destroy = true
  acl = "private"
}

resource "random_id" "webs_bucket_name" {
  prefix = "terraform-aws-lambda-builder-tests-"
  byte_length = 8
}

resource "aws_s3_bucket" "webs" {
  bucket = random_id.webs_bucket_name.hex
  force_destroy = true
  acl = "private"
}

data "aws_iam_policy_document" "s3_put_on_web" {
  statement {
    sid = "1"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.webs.id}/",
      "arn:aws:s3:::${aws_s3_bucket.webs.id}/*",
    ]
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = [
        "lambda.amazonaws.com"]
      type = "Service"
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "role" {
  name = "lambda-invoke"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_policy" "s3_put_on_web_policy" {
  name = "s3-put-on-web"
  path = "/"
  policy = data.aws_iam_policy_document.s3_put_on_web.json
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_put_on_web_policy.arn
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
  environment = {
    variables = {
      bucket_name = aws_s3_bucket.webs.id
    }
  }
  # Enable build functionality.
  build_mode = "LAMBDA"
  source_dir = "${path.module}/persister"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
  create_role = true
  role = aws_iam_role.role.arn
}

output "function_names" {
  value = [
    module.lambda_function_downloader.function_name,
    module.lambda_function_persister.function_name,
  ]
}
