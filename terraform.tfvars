
public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbLe9ZtDJVL7gbSEl8V6U3Z1XsiH1icFbSCAa/HkUug+EGnPwG55k983e9FulBEp1L1R/gw6WloyfDHYBCH+EMd66SzOQ46KDezIckKIkk2Rb7BWtZeR8QV3e0ZsOd0RzKUyOoTaB1v9X2omxMHVB2I/XJ6A/q807cx5J0lEvzOhgbMCcYC/zFnCWMf+WwnZX46iFtG0DhiUFZoYm6QV9NeNc84KngyrxoWbf3NZ2KzVmOjVx77ug5ReumEItHv/2glrOK/pjAhAJ2xVkFdMuIs1B+va9jxKFiYWdS8idfyUnUfddWFKV8AhlvzdKzhh3vY0c2Mm8L/yBcH68QXDoB abhishek"
name           = "Abhishek"
value          = "terraform test"

vpc_cidr_block = {
  default = "10.3.0.0/16"
  devlopment = "10.0.0.0/16"
  UAT        = "10.1.0.0/16"
  production = "10.2.0.0/16"
}

instance_count = {
  default = 2
  devlopment = 2
  UAT        = 2
  production = 3
}

vpc_subnet_count = {
  default = 2
  devlopment = 2
  UAT        = 2
  production = 3
}
