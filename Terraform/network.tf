resource "aws_vpc" "synthesis-vpc" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = "true" 
    enable_dns_hostnames = "true" 
    enable_classiclink = "false"
    instance_tenancy = "default"
    
  tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-public-1" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.1.0/24"
    map_public_ip_on_launch = "true" 
    availability_zone = "${var.region}a"
    tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-public-2" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.2.0/24"
    map_public_ip_on_launch = "true" 
    availability_zone = "${var.region}b"
    tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-private-1" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.3.0/24"
    availability_zone = "${var.region}a"
    tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-private-2" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.4.0/24"
    availability_zone = "${var.region}b"
    tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-private-3" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.5.0/24"
    availability_zone = "${var.region}a"
    tags = local.tags
}

resource "aws_subnet" "synthesis-subnet-private-4" {
  
    vpc_id = "${aws_vpc.synthesis-vpc.id}"    
    cidr_block = "10.10.6.0/24"
    availability_zone = "${var.region}b"
    tags = local.tags
}

resource "aws_db_subnet_group" "synthesis-subnet-group" {  
  name       = "synthesis-subnet-group"
  subnet_ids = [aws_subnet.synthesis-subnet-private-1.id, aws_subnet.synthesis-subnet-private-2.id]
  tags = local.tags
}



################################
# Internet gateway - Debug
################################


resource "aws_internet_gateway" "synthesis-igw" {
    vpc_id = "${aws_vpc.synthesis-vpc.id}"
    
  tags = local.tags
}

resource "aws_route_table" "synthesis-public-crt" {
    vpc_id = "${aws_vpc.synthesis-vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.synthesis-igw.id}" 
    }
    tags = local.tags
}

resource "aws_route_table_association" "synthesis-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.synthesis-subnet-public-1.id}"
    route_table_id = "${aws_route_table.synthesis-public-crt.id}"
}
resource "aws_route_table_association" "synthesis-crta-public-subnet-2"{
    subnet_id = "${aws_subnet.synthesis-subnet-public-2.id}"
    route_table_id = "${aws_route_table.synthesis-public-crt.id}"
}

######################
## NAT GAteway
######################

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.synthesis-subnet-public-1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.synthesis-igw]
}

resource "aws_route_table" "synthesis-nat-crt" {
    vpc_id = "${aws_vpc.synthesis-vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0" 
        nat_gateway_id = aws_nat_gateway.nat.id
    }
    tags = local.tags
}

resource "aws_route_table_association" "synthesis-nat-private-subnet-3"{
    subnet_id = aws_subnet.synthesis-subnet-private-3.id
    route_table_id = "${aws_route_table.synthesis-nat-crt.id}"
}
resource "aws_route_table_association" "synthesis-nat-private-subnet-4"{
    subnet_id = aws_subnet.synthesis-subnet-private-4.id
    route_table_id = "${aws_route_table.synthesis-nat-crt.id}"
}
#######################
##  RDS
#######################

resource "aws_security_group" "rds" {
    vpc_id = "${aws_vpc.synthesis-vpc.id}"  
  name        = "rds-sg"
  description = "controls access to RDS"

  ingress {
    protocol    = "tcp"
    from_port   = 1433
    to_port     = 1433
    #cidr_blocks = ["41.1.0.0/16"]     #IP range on vodacom network for debugging
    security_groups    = [aws_security_group.ecs_tasks.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}