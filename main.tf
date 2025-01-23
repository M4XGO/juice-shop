resource "aws_instance" "juice-shop" {
  ami                    = "ami-031e4310b9132e755" #ubuntu with apache pre-installed
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.juice-shop-sg.id]
  key_name               = "deployer-key"

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nodejs -y
    sudo apt install npm -y
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    source ~/.bashrc
    nvm install 18
    nvm use 18
    npm install -g npm
    npm cache clean --force
    mkdir juice-shop
    cd juice-shop
    wget https://github.com/juice-shop/juice-shop/releases/download/v17.1.1/juice-shop-17.1.1_node18_linux_x64.tgz 
    tar -xvzf juice-shop-17.1.1_node18_linux_x64.tgz
    cd juice-shop_17.1.1/
    # npm install
    npm start
  EOF

  tags = { Name = "juice-shop" }
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


resource "aws_security_group" "juice-shop-sg" {
  name        = "juice-shop-sg"
  description = "Allow all"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
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

  tags = { Name = "juice-shop-sg" }
}