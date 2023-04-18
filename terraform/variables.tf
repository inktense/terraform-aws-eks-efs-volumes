variable "aws_region" {
  description = "Region where main resources should be created."
  type        = string
  default     = "eu-west-2"
}

variable "project_prefix" {
  description = "Project prefix for naming resources."
  type        = string
  default     = "aws-k8s-efs"
}

variable "tags" {
  description = "A map containing all the mandatory tags for the resources."
  type        = map(string)

  default = {
    Initialised = "2023-04-17"
    Project     = "aws-k8s-efs"
  }
}