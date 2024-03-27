resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Http from load balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-my-sg"
  }
}

resource "aws_security_group" "load_balancer_sg" {
  name        = "${var.env_code}-load-balancer"
  description = "Allow HTTPS to the load balanacer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "TCP FROM ANYWHERE"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-loadbalancer-my-sg"
  }
}
