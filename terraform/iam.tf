# -------------------------------
# Cluster IAM Role
# -------------------------------

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "eks_role" {
  name = "eks_admin_role"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
  
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# resource "aws_iam_role_policy_attachment" "AmazonEKS_EFS_CSI_Driver_Policy" {
#   policy_arn = "arn:aws:iam::635567262396:policy/AmazonEKS_EFS_CSI_Driver_Policy"
#   role       = aws_iam_role.eks_role.name
# }

resource "aws_iam_role_policy_attachment" "AmazonElasticFileSystemFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  role       = aws_iam_role.eks_role.name
}

# -------------------------------
# Node IAM Role
# -------------------------------
resource "aws_iam_role" "node_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}


resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonElasticFileSystemFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  role       = aws_iam_role.node_role.name
}


# resource "aws_iam_role_policy_attachment" "node-AmazonEKS_EFS_CSI_Driver_Policy" {
#   policy_arn = "arn:aws:iam::635567262396:policy/AmazonEKS_EFS_CSI_Driver_Policy"
#   role       = aws_iam_role.node_role.name
# }