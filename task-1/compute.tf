data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "public_key" {
  key_name   = "ec2-key"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ec2_sg" {
  name        = "test-ec2-sg"
  description = "Allow HTTP from anywhere and SSH only from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Http web server"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access - Marko Home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "ICMP- Marko Home IP"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.public_key.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    amazon-linux-extras install postgresql14 -y
    EOF

  tags = {
    Name        = "test-ec2"
    Description = "Test instance"
    CostCenter  = "123456"
  }
}