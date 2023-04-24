resource "aws_eks_cluster" "k8s-efs" {
  name     = "${var.project_prefix}-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  }

  tags = local.tags
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.k8s-efs.name
  node_group_name = "efs-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_default_subnet.default_az1[*].id

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = local.tags
}
