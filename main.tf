provider "aws" {
  region = "us-east-1"
}

variable "web_instance_type" {
  default = "t2.medium"
}

variable "app_instance_type" {
  default = "t3.large"
}

variable "db_instance_type" {
  default = "m5.large"
}

resource "aws_instance" "web_vm" {
  ami           = "ami-xxxxxxxx" # Replace with RHEL 9 or Windows 2022 AMI
  instance_type = var.web_instance_type
  tags = {
    Name = "WebServer"
    Role = "Web"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum install -y nodejs
              npm install -g @angular/cli@18.5
              EOF
}

resource "aws_instance" "app_vm" {
  ami           = "ami-xxxxxxxx"
  instance_type = var.app_instance_type
  tags = {
    Name = "AppServer"
    Role = "App"
  }
  user_data = <<-EOF
              #!/bin/bash
              yum install -y dotnet-sdk-8
              yum install -y java-23
              EOF
}

resource "aws_instance" "db_vm" {
  ami           = "ami-xxxxxxxx"
  instance_type = var.db_instance_type
  tags = {
    Name = "DBServer"
    Role = "Database"
  }
}
