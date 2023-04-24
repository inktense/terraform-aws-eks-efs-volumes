resource "aws_efs_file_system" "efs" {
  creation_token   = "k8s-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  depends_on = [
    aws_eks_cluster.k8s-efs,
    aws_eks_node_group.node,
  ]

  tags = local.tags
}

# Mount targets in each AZ for the EFS file system with the EKS cluster security group
resource "aws_efs_mount_target" "az1" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_default_subnet.default_az1.id

  security_groups = [
    aws_eks_cluster.k8s-efs.vpc_config[0].cluster_security_group_id
  ]
}

resource "aws_efs_mount_target" "az2" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_default_subnet.default_az2.id

  security_groups = [
    aws_eks_cluster.k8s-efs.vpc_config[0].cluster_security_group_id
  ]
}
