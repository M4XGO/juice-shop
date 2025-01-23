resource "aws_instance" "web_vm" {
  ami                    = "ami-031e4310b9132e755" #ubuntu with apache pre-installed
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "deployer-key"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd
    echo "<h1>Bienvenue sur la VM Web</h1>" > /var/www/html/index.html
  EOF

  tags = { Name = "Web-VM" }
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "main_vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main_igw" }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                 = aws_vpc.main.id
  cidr_block             = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone      = "eu-west-3a"
  tags = { Name = "main_subnet" }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "main_rt" }
}

resource "aws_route_table_association" "main_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}


esource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow traffic from Suricata and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from Suricata"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.suricata_sg.id]  # Autoriser depuis le SG Suricata
  }

  ingress {
    description     = "SSH from anywhere"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web_sg" }
}