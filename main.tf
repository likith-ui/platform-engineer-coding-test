provider "aws" {
  region = "us-east-1"
}

resource "aws_sns_topic" "incident_alerts" {
  name = "incident-alerts"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-ec2-remediation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-ec2-sns-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:RebootInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "sns:Publish"
        Resource = aws_sns_topic.incident_alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "api-app-server"
  }
}

resource "aws_lambda_function" "remediation_lambda" {
  function_name = "api-latency-remediation"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  filename = "lambda.zip"

  environment {
    variables = {
      INSTANCE_ID   = aws_instance.app_server.id
      SNS_TOPIC_ARN = aws_sns_topic.incident_alerts.arn
    }
  }
}