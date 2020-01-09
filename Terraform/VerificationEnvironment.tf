resource "aws_vpc" "verification-vpc" {
    cidr_block  =   "10.10.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags = {
      Name = "tf-verification-vpc"
    }
}

resource "aws_internet_gateway" "verification-gateway" {
  vpc_id = aws_vpc.verification-vpc.id
  tags = {
      Name = "verification_internet_getaway"
  }
}

resource "aws_route_table" "verification-routetable" {
  vpc_id = aws_vpc.verification-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.verification-gateway.id
  }
  tags = {
    Name = "verification-routetable"
  }
}

resource "aws_subnet" "verification-subnet" {
  vpc_id = aws_vpc.verification-vpc.id
  cidr_block = "10.10.10.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "verification-subnet"
  }
}

resource "aws_route_table_association" "verification_association" {
  subnet_id = aws_subnet.verification-subnet.id
  route_table_id = aws_route_table.verification-routetable.id
}

resource "aws_security_group" "verification-securitygroup" {
    name = "verification-sg"
    vpc_id = aws_vpc.verification-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3128
        to_port = 3128
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    description = "tf-verification-securitygroup-sg"
}

resource "aws_key_pair" "tf-verification_key" {
    key_name = "public_key_WVP"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxKkd6i5L6/DV4qh+/DwVqlTuLeF3pyXsOL9xy9ZeU1xwZAyylwNPuw45SYq32teAOW6exPxjtYIPUDseSh6zFv7DM1tbsBsAN3GvjGHRiQVxbSu6iorGYHEeI5HJASsvEhbkPysi07jS9D6lp93j6wZcX0EYE6SnPEcjvy82MyY/Q42C6PFXz7HNjEZA366ZwIsaqZmWAcG0NMeMgRmignTuzRMZlzIRgLyE7QdLQ2KjDvTBSJof0U51evkmcIoOwDViK/M2BD852agPh3madLEMwJVfKPJGkrCObqE5EEvnGJJO7HhknwpnW/wcxfBXJPVslYwBWu9xcLkjGKCNT hardwolf@HardWolfnoMacBook-Pro.local"
}

resource "aws_instance" "bastion" {
    count   =   var.replicaset 
    ami     =   "ami-00e9cabdaec64b5b0"
    instance_type   =   "t2.micro"
    key_name    =   aws_key_pair.tf-verification_key.key_name
    vpc_security_group_ids  = [aws_security_group.verification-securitygroup.id]
    subnet_id               = aws_subnet.verification-subnet.id
    tags = {
        Name    =   "${format("verification-%02d",count.index +1 )}"
    }
}

resource "aws_eip" "bastion-eip" {
    count = var.replicaset
    vpc = true
    instance = element(aws_instance.bastion.*.id, count.index)
    tags = {
        Name    =   "${format("bastion-eip-%02d",count.index + 1)}"
    }
}

resource "aws_instance" "verification" {
    count   =   var.replicaset 
    ami     =   "ami-00e9cabdaec64b5b0"
    instance_type   =   "t2.micro"
    key_name    =   aws_key_pair.tf-verification_key.key_name
    vpc_security_group_ids  = [aws_security_group.verification-securitygroup.id]
    subnet_id               = aws_subnet.verification-subnet.id
    tags = {
        Name    =   "${format("verification-%02d",count.index +1 )}"
    }
}

