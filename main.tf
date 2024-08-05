resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr

}
resource "aws_subnet" "my_subnet1" {
    vpc_id = aws_vpc.my_vpc.id // calling vpc_id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  
}
resource "aws_subnet" "my_subnet2" {
    vpc_id = aws_vpc.my_vpc.id // calling vpc_id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id // calling vpc_id

}
resource "aws_route_table" "my_RT" {
    vpc_id = aws_vpc.my_vpc.id // calling vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id //calling igw

    }

}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.my_subnet1.id // calling subnet_id
   route_table_id = aws_route_table.my_RT.id // calling route_table_id
}
resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.my_subnet2.id // calling subnet_id
   route_table_id = aws_route_table.my_RT.id // calling route_table_id
}

resource "aws_security_group" "websg" {
    name= "web-sg"
    vpc_id = aws_vpc.my_vpc.id
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }
     ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

     egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }
    tags = {
        name = "web_sg"
    }
  
}

resource "aws_s3_bucket" "mybkt" {
    bucket = "myawsterrafoms3bucketproject"
  
}

resource "aws_instance" "webserver1" {
    ami = "ami-04a81a99f5ec58529"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.my_subnet1.id
    user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
    ami = "ami-04a81a99f5ec58529"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.my_subnet2.id
    user_data = base64encode(file("userdata1.sh"))
}

