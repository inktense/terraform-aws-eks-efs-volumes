terraform {
  backend "s3" {
    bucket  = "tf-state-202201108659685447"
    key     = "k8s-efs.tfstate"
    region  = "eu-west-2"
    encrypt = true
    acl     = "private"
  }
}