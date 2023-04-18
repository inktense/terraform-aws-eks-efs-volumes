resource "aws_efs_file_system" "efs" {
  creation_token   = "k8s-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = local.tags
}