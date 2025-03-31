terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

# VPC
resource "aws_vpc" "web_server_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "web_server_vpc"
  }

}

# Internet Gateway 
resource "aws_internet_gateway" "web_server_igw" {
  vpc_id = aws_vpc.web_server_vpc.id

  tags = {
    Name = "web_server_igw"
  }
}

#public subnet
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.web_server_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "public_subnet_a"
  }
}

#additional public subnet in a different AZ
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.web_server_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"

  tags = {
    Name = "public_subnet_b"
  }
}

#private subnet
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.web_server_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private_subnet_a"
  }
}

#private subnet
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.web_server_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private_subnet_b"
  }
}

#EC2 instance in public subnet A
resource "aws_instance" "app_server_1" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = var.instance1_name
  }
}

#EC2 instance in public subnet b
resource "aws_instance" "app_server_2" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = var.instance2_name
  }
}

# Security group for public subnets
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Open port 80"
  vpc_id      = aws_vpc.web_server_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

}

# Subnet group for RDS is all private subnets 
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]

  tags = {
    Name = "rds_subnet_group"
  }
}

# Security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Open port 3306"
  vpc_id      = aws_vpc.web_server_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_sg.id] # Allow access from web_server_sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

}


# RDS instance
resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "rds_instance"
  username             = "user"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot  = true

  tags = {
    Name = "rds_instance"
  }
}