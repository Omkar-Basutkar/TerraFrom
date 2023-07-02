provider "aws" {
  region     = "ap-south-1"
  access_key = "*****************"
  secret_key = "****************"
}




}

resource "aws_instance" "myec2" {
  ami           = "ami-057752b3f1d6c4d6c"
  instance_type = "t2.micro"



  key_name               = "tf-key-pair"
  vpc_security_group_ids = [aws_security_group.mysggrp1.id]
  tags = {
    Name = "first"
  }
}
resource "aws_security_group" "mysggrp1" {
  name = "mysggrp1"



  ingress {
    to_port     = var.server_port
    from_port   = var.server_port
    protocol    = "tcp"
    cidr_blocks = var.public_cidr
  }
  ingress {
    to_port     = var.ssh_port
    from_port   = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.public_cidr
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = var.public_cidr
  }



}



resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
}



output "public_ip" {



  value = aws_instance.myec2.public_ip
}
