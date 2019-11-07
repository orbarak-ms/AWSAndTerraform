provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "homework1-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.homework1-key.public_key_openssh}"
}

resource "aws_security_group" "homework1-security-group" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server1" {
  ami             = "ami-024582e76075564db"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.homework1-security-group.id]
  associate_public_ip_address = true
   
  tags = {
    Name = "server1"
	Owner = "Ory Barak"
	Purpose = "Learning"
  }
  
  ebs_block_device {
    device_name = "/dev/sdg"
    volume_size = 10
    volume_type = "gp2"
  }
  
	key_name = "${aws_key_pair.generated_key.key_name}"

	provisioner "file" {
		source      = "index.html"
		destination = "/tmp/index.html"
    }

	provisioner "remote-exec" {
		inline=[
			"sudo apt-get -y update",
			"sudo apt-get -y install nginx",
			"sudo service nginx start",
			"sudo mv -f /tmp/index.html /var/www/html/"
		]
	}

	connection {
		type = "ssh"
		host = aws_instance.server1.public_ip
		user = "ubuntu"
		private_key = "${tls_private_key.homework1-key.private_key_pem}"
	}
}

resource "aws_instance" "server2" {
  ami             = "ami-024582e76075564db"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.homework1-security-group.id]
  associate_public_ip_address = true
    
  tags = {
    Name = "server2"
	Owner = "Ory Barak"
	Purpose = "Learning"
  }
  
  ebs_block_device {
    device_name = "/dev/sdg"
    volume_size = 10
    volume_type = "gp2"
  }

  key_name = "${aws_key_pair.generated_key.key_name}"
	
	provisioner "file" {
		source      = "index.html"
		destination = "/tmp/index.html"
    }
  
	provisioner "remote-exec" {
		inline=[
			"sudo apt-get -y update",
			"sudo apt-get -y install nginx",
			"sudo service nginx start",
			"sudo mv -f /tmp/index.html /var/www/html/"
		]
	}
		
	connection {
		type = "ssh"
		host = self.public_ip
		user = "ubuntu"
		private_key = "${tls_private_key.homework1-key.private_key_pem}"
	}
}
