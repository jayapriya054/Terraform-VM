terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.16.2"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-west-1"
  profile = "default"
}

resource "aws_vpc" "awsvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "awsvpc"
  }
}
resource "aws_subnet" "awssubnet-1a" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "awssubnet-1a"
  }
}
resource "aws_subnet" "awssubnet-1b" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "awssubnet-1b"
  }
}
resource "aws_subnet" "awssubnet-1c" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = "us-west-1a"

  tags = {
    Name = "awssubnet-1c"
  }
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.awsvpc.id

  tags = {
    Name = "gateway"
  }
}
  
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.awsvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "rt_public"
  }
}

resource "aws_route_table_association" "rt_public_ass_1a" {
  subnet_id      = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "rt_public_ass_1b" {
  subnet_id      = aws_subnet.subnet-1b.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_instance" "machine-1a" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
}  

resource "aws_instance" "machine-1b" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
}  

resource "aws_instance" "machine-1c" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
}  

resource "aws_instance" "machine-2a" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
}  

resource "aws_instance" "machine-2b" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
}  

resource "aws_instance" "machine-2c" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
}  



resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.awsvpc.id

  #route {
   # cidr_block = "0.0.0.0/0"
    #gateway_id = aws_internet_gateway.gateway.id
  #}

  tags = {
    Name = "rt_private"
  }
}

resource "aws_route_table_association" "rt_private_ass_1b" {
  subnet_id      = aws_subnet.subnet-1b.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_route_table_association" "rt_private_ass_1c" {
  subnet_id      = aws_subnet.subnet-1c.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_instance" "machine-3a" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
}  

resource "aws_instance" "machine-3b" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
}  

resource "aws_instance" "machine-3c" {
  ami           = "ami-05c969369880fa2c2"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
}  

resource "aws_security_group" "webservers_lb" {
  description = "Load balancer security group "
  name   = "Webserver_lb"
  ingress {
    description = "HTTP from world"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webservers" {
  description = "Handles HTTP inbound traffic of each machine"
  name   = "Webservers"
  ingress {
    description = "HTTP from world"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress {
    description = "HTTP from world"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  }

  resource "aws_lb_target_group" "targetgroup" {
  name     = "targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.awsvpc.id
}

resource "aws_lb_target_group_attachment" "attach-machine-1a_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-1a.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-1b_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-1b.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-1c_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-1c.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach-machine-2a_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-2a.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-2b_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-2b.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-2c_totargetgroup" {
  target_group_arn = aws_lb_target_group.targetgroup.arn
  target_id        = aws_instance.machine-2c.id
  port             = 80
}

resource "aws_lb" "webservers_lb" {
  name               = "webservers_lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webservers_lb.id]
  subnets            = [aws_subnet.aws_subnet-1a.id , aws_subnet.aws_subnet-1b.id,aws_subnet.aws_subnet-1b.id]

  tags = {
    Environment = "preview"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webservers_lb.arn
  port              = "80"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}