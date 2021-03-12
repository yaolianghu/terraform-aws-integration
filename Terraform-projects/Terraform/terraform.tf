variable "subnet_prefix" {
    default = "10.0.1.0/24"
}

variable "ami" {
    default = "ami-0915bcb5fa77e4892"
}

variable "instance_type" {
      default = "t2.micro"
}

variable "availability_zone" {
      default = "us-east-1a"
}

variable "key_name" {
      default = "yhu-access-key"
}

variable "jar_name" {
      default = "demo-0.0.1-SNAPSHOT.jar"
}