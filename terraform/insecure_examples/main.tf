resource "aws_security_group" "insecure_ssh" {
  name        = "insecure-ssh-demo"
  description = "Intentionally insecure security group for Checkov testing"

  ingress {
    description = "SSH open to the entire Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}