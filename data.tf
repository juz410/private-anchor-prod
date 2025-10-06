data "aws_ami" "amazon_linux" {
  owners = ["self"] # your account

  filter {
    name   = "image-id"
    values = ["ami-00968c4a471ceb592"]
  }
}
