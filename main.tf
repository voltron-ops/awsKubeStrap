provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "cluster-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    "Name"        = "k8scluster-vpc"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_subnet" "cluster-subnet" {
  vpc_id            = aws_vpc.cluster-vpc.id
  cidr_block        = var.subnets
  tags = {
    "Name"        = "k8scluster-subnet"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_internet_gateway" "cluster-ig" {
  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    "Name"        = "k8scluster-ig"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_route_table" "cluster-route-table" {
  vpc_id = aws_vpc.cluster-vpc.id
  route = [{
    cidr_block                 = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.cluster-ig.id
    carrier_gateway_id         = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    instance_id                = ""
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = ""
  }]

  tags = {
    "Name"        = "Cluster VPC Route Table"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_route_table_association" "cluster-vpc-rt-subnet" {
  subnet_id      = aws_subnet.cluster-subnet.id
  route_table_id = aws_route_table.cluster-route-table.id
}

resource "aws_security_group" "cluster-sg" {
  name        = "allow_ssh"
  description = "Allow SSH Inbound Connections"
  vpc_id      = aws_vpc.cluster-vpc.id

  ingress = [
    {
      description      = "SSH"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 22
      protocol         = "tcp"
      to_port          = 22
      security_groups  = []
      self             = false
    }
  ]


  egress = [
    {
      description      = "Allow Outbound Traffic"
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 0
      protocol         = "-1"
      to_port          = 0
      security_groups  = []
      prefix_list_ids  = []
      ipv6_cidr_blocks = []
      self             = false
    }
  ]

  tags = {
    "Name"        = "Allow SSH for Inbound"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

data "aws_ami" "latest_ami_ap" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "master-node"{
    ami = data.aws_ami.latest_ami_ap.id
    associate_public_ip_address = "true"
    key_name      = "EC2-AMI-Key"
    instance_type = "t2.medium"
    security_groups = [aws_security_group.cluster-sg.id]
    subnet_id = aws_subnet.cluster-subnet.id
    user_data = file("kubestrap.sh")

    tags = {
    "Name"        = "K8s Master Node"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_instance" "worker-node01"{
    ami = data.aws_ami.latest_ami_ap.id
    associate_public_ip_address = "true"
    key_name      = "EC2-AMI-Key"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.cluster-sg.id]
    subnet_id = aws_subnet.cluster-subnet.id
    user_data = file("kubestrap.sh")

    tags = {
    "Name"        = "K8s Worker Node 01"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

resource "aws_instance" "worker-node02"{
    ami = data.aws_ami.latest_ami_ap.id
    associate_public_ip_address = "true"
    key_name      = "EC2-AMI-Key"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.cluster-sg.id]
    subnet_id = aws_subnet.cluster-subnet.id
    user_data = file("kubestrap.sh")

    tags = {
    "Name"        = "K8s Worker Node 02"
    "environment" = "dev"
    "terraform"   = "true"
  }
}

