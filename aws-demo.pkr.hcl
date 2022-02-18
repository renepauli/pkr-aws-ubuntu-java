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
  default = "packer-aws-ubuntu-java"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu_java" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  source_ami    = "ami-0a5b876f0c0ac51b0"
  instance_type = "t2.micro"
  region        = "eu-central-1"
  encrypt_boot  = true
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
}

build {
  name    = "packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu_java"
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
