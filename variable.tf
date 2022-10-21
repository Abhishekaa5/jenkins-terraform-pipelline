variable "aws_region" {
  type        = string
  description = "AWS Regions"
  default     = "ap-south-1"
}

variable "vpc_cidr_block" {
  type        = map(string)
  description = "ip range of vpc"
}




variable "port" {
  type        = map(number)
  description = "port available to from and to"
  default = {
    HTTP = "80"
    SSH  = "22"
    RDS  = "5432"
  }
}

variable "protocol" {
  type        = list(string)
  description = "tcp or udp protocol"
  default     = ["tcp", "HTTP"]
}


variable "ami" {
  type        = string
  description = "amazon linx ami"
  default     = "ami-01216e7612243e0ef"
  sensitive   = true
}

variable "instance_type" {
  type        = string
  description = " decribe type of instance "
  default     = "t2.micro"
}

variable "RDSengine" {
  type        = string
  description = "name of database engine"
  default     = "postgres"
}

variable "RDSinstance_class" {
  type        = string
  description = "type of instance classes"
  default     = "db.t3.micro"
}

variable "username" {
  type        = string
  description = "value"
  default     = "abhishek"
}

variable "password" {
  type        = string
  description = "value"
  default     = "postgresql"
  sensitive   = true
}

variable "internal" {
  type        = bool
  description = "value of internal"
  default     = false
}

variable "load_balancer_type" {
  type        = string
  description = "type of lb"
  default     = "application"
}

variable "ip_address_type" {
  type        = string
  description = "ipv4 or ipv6"
  default     = "ipv4"
}

variable "listener_type" {
  type        = string
  description = "type of listener "
  default     = "forward"
}

variable "public_key" {
  type      = string
  sensitive = true
}

variable "name" {
  type = string
}
variable "value" {
  type = string
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "instance_count" {
  type = map(number)
}

variable "vpc_subnet_count" {
  type = map(number)
}

variable "naming_prefix" {
  type    = string
  default = "testabhishek"
}
