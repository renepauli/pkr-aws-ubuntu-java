packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "runner-ubuntu"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu_runner" {
  ami_name = "${var.ami_prefix}-${local.timestamp}"
  source_ami = "ami-0e90768436805c374"
  instance_type = "t2.micro"
  region = "eu-central-1"
  associate_public_ip_address = true
  encrypt_boot = true
  vpc_filter {
    filters = {
      "tag:Class": "runners"
    }
  }
  subnet_filter {
    filters = {
      "tag:Class": "runners"
    }
  }
  ssh_username = "ubuntu"
  ssh_interface = "public_ip"
}

build {
  name    = "packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu_runner"
  ]

  provisioner "shell" {

    inline = [
      "echo Install Open JDK 8 - START",
      "sleep 10",
      "sudo apt-get update",
      "sudo apt-get install -y openjdk-8-jdk",
      "echo Install Open JDK 8 - SUCCESS",
    ]
  }
}
