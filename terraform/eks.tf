resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "Default subnet for eu-west-2a"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "Default subnet for eu-west-2b"
  }
}

resource "aws_eks_cluster" "k8s-efs" {
  name     = "${var.project_prefix}-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  }
}