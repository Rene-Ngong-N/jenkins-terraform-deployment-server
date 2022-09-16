# Terraform Block
terraform {
  required_version = ">= 0.14" 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    } 
  }
}

# Provider Block
provider "aws" {
  region  = "us-west-1"
  profile = "default"
}

# Security Group
variable "ingressrules" {
  type    = list(number)
  default = [8080, 22]
}

resource "aws_security_group" "web_traffic" {
  name        = "web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" { #iterator = port
    for_each = var.ingressrules
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }

    #   dynamic "ingress" {
    # for_each = var.service_ports
    # content {
    #   from_port = ingress.value
    #   to_port   = ingress.value
    #   protocol  = "tcp"
    # }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

data "aws_ami" "redhat" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

# resource block
resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.redhat.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "prud-key"

  tags = {
    "Name" = "Jenkins"  }
}

# Create a Null Resource and Provisioners
resource "null_resource" "name" {
  depends_on = [aws_instance.jenkins]
  # Connection Block for Provisioners to connect to EC2 Instance
  connection {
    type        = "ssh"
    host        = aws_instance.jenkins.public_ip
    user        = "ec2-user"
    password    = ""
    private_key = file("prud-key.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install java-11-openjdk -y",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
      "sudo yum install jenkins -y",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sudo pip3 install boto3",
      "sudo yum install git -y",
    ]
  }
}

# jenkins server URL
output "jenkins_server_ip" {
  description = "public IP address of jenkins server"
  value       = aws_instance.jenkins.public_ip 
}
