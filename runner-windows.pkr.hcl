packer {
#  required_plugins {
#    amazon = {
#      version = ">= 0.0.2"
#      source  = "github.com/hashicorp/amazon"
#    }
#  }
}

variable "ami_prefix" {
  type    = string
  default = "runner-windows"
}

variable "image_folder" {
  type    = string
  default = "/imagegeneration"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "windows_runner" {
  ami_name = "${var.ami_prefix}-${local.timestamp}"
  source_ami = "ami-07da315d4e55175ff"
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
  user_data_file = "./winrm_bootstrap.txt"
  communicator = "winrm"
  force_deregister = true
  winrm_insecure = true
  winrm_username = "Administrator"
  winrm_use_ssl = true
}

build {
  name    = "packer-windows"
  sources = [
    "source.amazon-ebs.windows_runner"
  ]
}