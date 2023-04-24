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
