resource "aws_vpc" "aurora_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-security-group"
  description = "Security group for Aurora MySQL instance"
  vpc_id      = aws_vpc.aurora_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # EXPOSED TO ALL IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # EXPOSED TO ALL IP
  }
}
