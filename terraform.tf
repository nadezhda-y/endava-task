provider "aws" {
access_key="your_access_key"
secret_key="your_secret_keys"
region="us-east-1"
}

variable "pvt_key" {}
variable "pub_key" {}

resource "aws_key_pair" "generated_key" {
  key_name   = "ssh1"
  public_key = file(var.pub_key)
}
resource "aws_security_group" "instance" {
  name = "http"
  ingress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

  egress {
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
  ami                    = "ami-093b8289535bbca9a"
  instance_type          = "t2.micro"
  monitoring             = true

  key_name               = "ssh1"
  vpc_security_group_ids = [aws_security_group.instance.id]
  tags          = {
    Name        = "web"
    Environment = "production"
  }
   root_block_device {
    delete_on_termination = false
  }


provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
  
connection {
      host        = aws_instance.web.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
      }
    }

provisioner "local-exec" {
    command = "echo docker ansible_host=${aws_instance.web.public_ip} > ansible/inventory"
  } 

provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i ansible/inventory --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ansible/playbooks/install-all.yml"
  }
}
  

