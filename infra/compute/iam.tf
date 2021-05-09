#system manager access
resource "aws_iam_role" "pg_cluster_role" {
  name = "pg_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "pg_cluster_policy" {
  name = "pg_cluster_policy"
  role = aws_iam_role.pg_cluster_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
          "ssm:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "pg_cluster_profile" {
  name = "pg_cluster_profile"
  role = aws_iam_role.pg_cluster_role.name
}