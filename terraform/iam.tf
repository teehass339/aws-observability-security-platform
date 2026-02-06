resource "aws_iam_role" "ec2-role" {
  name = "ec2-observability-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  permissions_boundary = aws_iam_policy.ec2-boundary.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ec2-boundary" {
  name = "ec2-permissions-boundary"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:*",
          "ec2messages:*",
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      },
      {
        Effect : "Deny"
        Action = [
          "iam:*",
          "kms:*",
          "organizations:*",
          "s3:DeleteBucket",
          "cloudtrail:StopLogging"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-observability-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_policy" "secret" {
  name = "ec2-secret"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.app-secret.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secret" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.secret.arn

}

resource "aws_iam_role" "cloudtrail-role" {
  name = "cloudtrail-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail-role-policy" {
  role = aws_iam_role.cloudtrail-role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
    }]
  })
}