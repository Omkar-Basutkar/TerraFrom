provider "aws" {
 region="ap-south-1"
access_key = "AKIASIND6DRKWK2E6PYQ"
  secret_key = "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"
}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
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

resource "aws_vpc""customvpc" {
cidr_block="10.0.0.0/16"
tags= {
Name="Custom_vpc"
}
}

resource"aws_internet_gateway" "custominternetgateway" {
vpc_id="aws_vpc.customvpc.id"
}

resource "aws_subnet" "websubnet" {
cidr_block="10.0.0.0/20"
vpc_id="awsvpc.customvpc.id"
availability_zone="ap_south_1a"
}

resource "aws_subnet" "appsubnet" {
cidr_block="10.0.16.0/20"
vpc_id="awsvpc.customvpc.id"
availability_zone="ap_south_1b"
}

resource "aws_subnet" "dbsubnet" {
cidr_block="10.0.32.0/20"
vpc_id="awsvpc.customvpc.id"
availability_zone="ap_south_1a"
}

resource "aws_route_table" "publicroutetable" {
vpc_id="awsvpc.customvpc.id"
route {
cidr_block="0.0.0.0/0"
gateway_id="aws_internet_gateway.custominternetgateway.id"
}
}

resource "aws_route_table""pvtroutetable" {
vpc_id="awsvpc.customvpc.id"
}

resource "aws_route_table_association""publicassociation" {
subnet_id= "aws_subnet.websubnet.id"
route_table_id="aws_route_table.publicroutetable.id"
}

resource "aws_route_table_association""privateassociationroutetable" {
subnet_id= aws_subnet.appsubnet.id
route_table_id=aws_route_table.pvtroutetable.id
}

resource "aws_route_table_association""privateroutetable" {
subnet_id= aws_subnet.dbsubnet.id
route_table_id=aws_route_table.pvtroutetable.id
}


resource "aws_instance" "myec2" {
ami= "ami-0d81306eddc614a45"
instance_type= "t2.micro"
vpc_security_group_ids=[aws_security_group.websg.id]
subnet_id= aws_subnet.websubnet.id
key_name = "tf-key-pair"
tags={
 Name="terraform-example"
}
}
resource "aws_security_group" "websg" {
 name="web-sg"
ingress {
 from_port=80
 to_port=80
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}
ingress {
 from_port=22
 to_port=22
protocol="tcp"
cidr_blocks=["0.0.0.0/0"]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"]
}
}

resource "aws_security_group" "appsg" {
 name="app-sg"
ingress {
 from_port=9000
 to_port=9000
protocol="tcp"
cidr_blocks= [aws_security_group.websg.id]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"]
}

}


resource "aws_security_group" "dbsg" {
 name="app-sg"
ingress {
 from_port=3306
 to_port=3306
protocol="tcp"
cidr_blocks=[aws_security_group.appsg.id]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks=["0.0.0.0/0"]
}
}
