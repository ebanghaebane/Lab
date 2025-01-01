terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" { default = "vpc-0bb2b71521ab3e99b" } 
variable "subnet_id" { default = "subnet-xxxxxxxx" }     
variable "web_instance_type" { default = "t2.micro" }
variable "app_instance_type" { default = "t2.micro" }
variable "db_instance_type" { default = "t2.micro" }

resource "aws_security_group" "example_sg" {
  name_prefix = "example-sg"
  vpc_id      = var.vpc_id
  description = "Allow SSH, HTTP, and Database traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "example-sg" }
}

resource "aws_instance" "web_vm" {
  ami                    = "ami-0e2c8caa4b6378d8c"  # RHEL 9 or Windows 2022
  instance_type          = var.web_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  associate_public_ip_address = true
  tags = { Name = "WebServer", Role = "Web" }

  user_data = <<-EOF
    #!/bin/bash
    yum install -y nodejs
    npm install -g @angular/cli@18.5
  EOF
}

resource "aws_instance" "app_vm" {
  ami                    = "ami-0e2c8caa4b6378d8c"
  instance_type          = var.app_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  associate_public_ip_address = true
  tags = { Name = "AppServer", Role = "App" }

  user_data = <<-EOF
    #!/bin/bash
    yum install -y dotnet-sdk-8
    yum install -y java-23
  EOF
}

resource "aws_instance" "db_vm" {
  ami                    = "ami-0e2c8caa4b6378d8c"
  instance_type          = var.db_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  associate_public_ip_address = false 
  tags = { Name = "DBServer", Role = "Database" }
}
