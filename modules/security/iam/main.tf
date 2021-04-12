resource "aws_iam_role" "default" {
  name = var.role_name

  assume_role_policy = var.assume_role_policy

  tags = {
    Env = var.env
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = var.policy_arn
}