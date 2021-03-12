terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
# Find your aws credentials cat ~/.aws/credentials
provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "/Users/yhu/.aws/creds"
  profile                 = "yaolhu"
}

# 1. Create VPC VPC is the first step to setup network
resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "dev-vpn"
  }
}

# 2. Create Internet Gateway this will be used by route table to connect outside world
resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

# 3. Create Custom Route Table this will use the vpc + internet gateway to route network.
resource "aws_route_table" "dev-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.dev-gw.id
  }

  tags = {
    Name = "main"
  }
}

# 4. Create a Subnet Adding a new subnet within the same VPC but different AZ + IP range.
resource "aws_subnet" "dev-subnet-1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.subnet_prefix
  availability_zone = var.availability_zone

  tags = {
    Name = "dev-subnet-1"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dev-subnet-1.id
  route_table_id = aws_route_table.dev-rt.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "dev-allow-sg" {
  name        = "allow_web_traffic"
  description = "Allow traffic 20, 80, 443"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    # TLS (change to whatever ports you need)
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    # TLS (change to whatever ports you need)
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # TLS (change to whatever ports you need)
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    # TLS (change to whatever ports you need)
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
      Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet. That was created in step 4
resource "aws_network_interface" "dev-interface" {
  subnet_id       = aws_subnet.dev-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.dev-allow-sg.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.dev-interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.dev-gw]
}

output "server_public_ip" {
    value = aws_eip.one.public_ip
}

# 9. Create Censto 7 server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami           = var.ami
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  key_name = var.key_name

  network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.dev-interface.id
  }

# Install Apache2
#   user_data = <<-EOF
#                 #! /bin/bash
#                 sudo yum update
#                 sudo yum install -y httpd
#                 sudo chkconfig httpd on
#                 sudo service httpd start
#                 echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html
#                 EOF

    #Install Java 8
    # user_data = <<-EOF
    #         #!/bin/bash
    #         sudo yum update
    #         sudo yum install -y java-1.8.0-devel
    #         sudo /usr/sbin/alternatives --config java
    #         sudo update-alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
    #         sudo /usr/sbin/alternatives --config javac
    #         sudo update-alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac
    #         EOF

    tags = {
      Name = "us-east1-dev-test-api1"
    }
}

output "server_privat_ip" {
    value = [aws_instance.web-server-instance.private_ip, aws_instance.web-server-instance.id,  aws_instance.web-server-instance.public_ip]
}

resource "null_resource" "deploy" {
  provisioner "remote-exec" {
      inline = [
        "sudo yum -y update",
        "sudo yum install -y java-1.8.0-devel",
        "sudo /usr/sbin/alternatives --auto java",
        # "sudo update-alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java",
        "sudo /usr/sbin/alternatives --auto javac",
        # "sudo update-alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac",
        "java -version",
      ]
    }

    ### Copy the jar file into the new EC2 ###
    provisioner "file" {
        source      = "../HelloworldDemo/target/${var.jar_name}"
        destination = "/home/ec2-user/${var.jar_name}"
    }

    ### run command in the new EC2 ###
    provisioner "remote-exec" {
      inline = [
        # "sudo yum -y update",
        # "sudo yum install -y java-1.8.0-devel",
        # "sudo /usr/sbin/alternatives --config java",
        # "sudo update-alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java",
        # "sudo /usr/sbin/alternatives --config javac",
        # "sudo update-alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac",
        # "sh /home/ec2-user/rest-api.sh",
        # "export JAVA_HOME=/usr/bin/java",
        # "echo $JAVA_HOME",y
        "java  -version",
        "echo 'Starting API application ... '",
        "java  -jar /home/ec2-user/${var.jar_name} 2>&1 &",
      ]
    }

    connection {
        type     = "ssh"
        user     = "ec2-user"
        private_key = file("${var.key_name}.pem")
        host     = aws_instance.web-server-instance.public_ip
    }
}