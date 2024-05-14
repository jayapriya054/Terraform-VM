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
  region = "us-west-2"
  profile = "default"
}

resource "aws_vpc" "awsvpc" {
  cidr_block       = "10.0.0.0/16"            #need to give NEW VPC Always, if created already using this VPV cidr block, then dont five value
  instance_tenancy = "default"
  tags = {
    Name = "awsvpc"
  }
}
resource "aws_subnet" "awssubnet-1a" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.1.0/24"                    #use different cidrblock for subnets
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "awssubnet-1a"
  }
}
resource "aws_subnet" "awssubnet-1b" {          
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "awssubnet-1b"
  }
}
resource "aws_subnet" "awssubnet-1c" {
  vpc_id     = aws_vpc.awsvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"

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
  subnet_id      = aws_subnet.awssubnet-1a.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "rt_public_ass_1b" {
  subnet_id      = aws_subnet.awssubnet-1b.id
  route_table_id = aws_route_table.rt_public.id
}

#user_data block----to add external files to terraform file,giving permission to file , to run the file  (can add sh file here directly or aadd path of sh file)

resource "aws_instance" "machine-1a" {

  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
   tags = {
    Name = "machine-1a"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo 'Adding frontend.sh...'
              cat > /tmp/frontend.sh << 'EOL'
              #!/bin/bash
              # Add Docker's official GPG key:
              sudo apt-get update
              sudo apt-get install ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc

              # Add the repository to Apt sources:
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update

              # Install Docker CE
              sudo apt-get install -y docker-ce

              # Add the ubuntu user to the docker group
              sudo usermod -aG docker ubuntu
              #Docker login
              # Run a Docker container
              sudo docker run -d --name my-container -p 80:80 jayapriya054/demo-frontend:latest
              EOL
              chmod +x /tmp/frontend.sh
              /tmp/frontend.sh
              EOF
}

resource "aws_instance" "machine-1b" {                          #1 instance for each application is enough for preview stage to save cost nd time
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
   tags = {
    Name = "machine-1b"
  }
  user_data = <<-EOF
    ${file("frontend.sh")}
    chmod +x /tmp/frontend.sh
    sudo/tmp/frontend.sh
  EOF
}  

resource "aws_instance" "machine-1c" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1a.id
   tags = {
    Name = "machine-1c"
  }
  user_data = <<-EOF
    ${file("frontend.sh")}
    chmod +x /tmp/frontend.sh
    sudo/tmp/frontend.sh
  EOF
}  

resource "aws_instance" "machine-2a" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
    tags = {
    Name = "machine-2a"
  }
  user_data = <<-EOF
    ${file("backend1.sh")}
    chmod +x /tmp/backend1.sh
    sudo/tmp/backend1.sh
  EOF
}  

resource "aws_instance" "machine-2b" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
       tags = {
    Name = "machine-2b"
  }
  user_data = <<-EOF
    ${file("backend1.sh")}
    chmod +x /tmp/backend1.sh
    sudo/tmp/backend1.sh
  EOF
}  

resource "aws_instance" "machine-2c" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers_sg.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1b.id
       tags = {
    Name = "machine-2c"
  }
  user_data = <<-EOF
    ${file("backend1.sh")}
    chmod +x /tmp/backend1.sh
    sudo/tmp/backend1.sh
  EOF
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

resource "aws_route_table_association" "rt_private_ass_1c" {
  subnet_id      = aws_subnet.awssubnet-1c.id
  route_table_id = aws_route_table.rt_private.id
}

resource "aws_instance" "machine-3a" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webservers_python.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
       tags = {
    Name = "machine-3a"
  }
  user_data = <<-EOF
    ${file("backend2.sh")}
    chmod +x /tmp/backend2.sh
    sudo/tmp/backend2.sh
  EOF
}  

resource "aws_instance" "machine-3b" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.small"
  vpc_security_group_ids = [aws_security_group.webservers_python.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
       tags = {
    Name = "machine-3b"
  }
  user_data = <<-EOF
    ${file("backend2.sh")}
    chmod +x /tmp/backend2.sh
    sudo/tmp/backend2.sh
  EOF
}  

resource "aws_instance" "machine-3c" {
  ami           = "ami-0cf2b4e024cdb6960"
  instance_type = "t2.nano"
  vpc_security_group_ids = [aws_security_group.webservers_python.id]
  key_name = "jayapriya"
  monitoring = false
  subnet_id = aws_subnet.awssubnet-1c.id
       tags = {
    Name = "machine-3c"
  }
  user_data = <<-EOF
    ${file("backend2.sh")}
    chmod +x /tmp/backend2.sh
    sudo/tmp/backend2.sh
  EOF
}  

resource "aws_security_group" "webservers_sg" {  
  vpc_id     = aws_vpc.awsvpc.id                 #security group for vms in subnet 1a and 1b
  description = "Allows HTTP inbound traffic"
  name   = "Webservers_sg"

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
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  }

  resource "aws_security_group" "webservers_lb" {                   #security group for load balancer
  vpc_id     = aws_vpc.awsvpc.id 
  description = "Allows HTTP inbound traffic"
  name   = "Webservers_lb"
  ingress {
    description = "HTTP from world"              #  for network connectivity
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {                                      #connection to vm   
    description = "SSH from world"                            
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

resource "aws_security_group" "webservers_python" {                 #all Vms in any subnet in same VPC can communicate by default      
  vpc_id     = aws_vpc.awsvpc.id 
  description = "Allows inbound traffic within vpc"
  name   = "Webservers_python"
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/16"]
   
  }
}

  resource "aws_lb_target_group" "targetgroup1" {
  name     = "targetgroup1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.awsvpc.id                       #for 3 target groups of different port number, 3 load balancer listeners are required
}
 resource "aws_lb_target_group" "targetgroup2" {     # Can all target group port number be same?????-no
  name     = "targetgroup2"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.awsvpc.id                       #3 target groups, 3 listerns
}
 resource "aws_lb_target_group" "targetgroup3" {
  name     = "targetgroup3"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.awsvpc.id                       #3 target groups, 3 listerns
}

resource "aws_lb_target_group_attachment" "attach-machine-1a_totargetgroup1" {
  target_group_arn = aws_lb_target_group.targetgroup1.arn
  target_id        = aws_instance.machine-1a.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-1b_totargetgroup1" {
  target_group_arn = aws_lb_target_group.targetgroup1.arn
  target_id        = aws_instance.machine-1b.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach-machine-1c_totargetgroup1" {
  target_group_arn = aws_lb_target_group.targetgroup1.arn
  target_id        = aws_instance.machine-1c.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach-machine-2a_totargetgroup2" {
  target_group_arn = aws_lb_target_group.targetgroup2.arn
  target_id        = aws_instance.machine-2a.id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "attach-machine-2b_totargetgroup2" {
  target_group_arn = aws_lb_target_group.targetgroup2.arn
  target_id        = aws_instance.machine-2b.id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "attach-machine-2c_totargetgroup2" {
  target_group_arn = aws_lb_target_group.targetgroup2.arn
  target_id        = aws_instance.machine-2c.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "attach-machine-3a_totargetgroup3" {
  target_group_arn = aws_lb_target_group.targetgroup3.arn
  target_id        = aws_instance.machine-3a.id
  port             = 8081
}
resource "aws_lb_target_group_attachment" "attach-machine-3b_totargetgroup3" {
  target_group_arn = aws_lb_target_group.targetgroup3.arn
  target_id        = aws_instance.machine-3b.id
  port             = 8081
}
resource "aws_lb_target_group_attachment" "attach-machine-3c_totargetgroup3" {
  target_group_arn = aws_lb_target_group.targetgroup3.arn
  target_id        = aws_instance.machine-3c.id
  port             = 8081
}

resource "aws_lb" "webservers-loadbalancer" {
  name               = "webservers-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webservers_lb.id]                                # why no other security group?                            
  subnets            = [aws_subnet.awssubnet-1a.id , aws_subnet.awssubnet-1b.id,aws_subnet.awssubnet-1c.id]
  tags = {
    Environment = "preview"
  }
}

resource "aws_lb_listener" "front_end" {                       #port number for private and public targetgroup
  load_balancer_arn = aws_lb.webservers-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup1.arn
  }
}         
resource "aws_lb_listener" "back_end_1" {
  load_balancer_arn = aws_lb.webservers-loadbalancer.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup2.arn
  }
}  
resource "aws_lb_listener" "back_end_2" {
  load_balancer_arn = aws_lb.webservers-loadbalancer.arn
  port              = "8081"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup3.arn
  }
}                                                    
