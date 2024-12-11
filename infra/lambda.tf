data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "IntegrationLambdaRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_cognito_api_policy" {
  name = "IntegrationLambdaPolicy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = ["rds-data:*"]
        Effect = "Allow"
        Resource = [
          aws_rds_cluster.aurora.arn,
          "${aws_rds_cluster.aurora.arn}:*/*"
        ]
      }
    ]
  })
}

resource "null_resource" "package_lambda_layer" {
  provisioner "local-exec" {
    command = <<EOT
      set -e # Exit immediately if a command exits with a non-zero status

      cd ${path.module}/../lambda

      python3 -m venv venv
      . venv/bin/activate
      mkdir -p python

      pip install -r requirements.txt -t python/
      zip -r ../infra/layer.zip python/

      deactivate
      rm -rf venv python
    EOT
  }

  triggers = {
    requirements = filesha256("../lambda/requirements.txt")
  }
}

resource "aws_lambda_layer_version" "dependencies_layer" {
  filename            = "${path.module}/layer.zip"
  layer_name          = "postgres_layer"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = fileexists("${path.module}/layer.zip") ? filesha256("${path.module}/layer.zip") : ""

  depends_on = [null_resource.package_lambda_layer]

}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
  depends_on  = [aws_lambda_layer_version.dependencies_layer]
}

resource "aws_lambda_function" "lambda" {
  function_name = "IntegrationFunction"
  filename      = data.archive_file.lambda.output_path
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda.arn

  layers = [aws_lambda_layer_version.dependencies_layer.arn]

  vpc_config {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      SERVER_HOST     = aws_rds_cluster.aurora.endpoint
      SERVER_DATABASE = aws_rds_cluster.aurora.database_name
      SERVER_USER     = aws_rds_cluster.aurora.master_username
      SERVER_PASSWORD = aws_rds_cluster.aurora.master_password
    }
  }

  source_code_hash = fileexists("${path.module}/lambda.zip") ? filebase64sha256("${path.module}/lambda.zip") : ""

  depends_on = [data.archive_file.lambda]
}
