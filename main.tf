provider "aws" {
  region     = var.aws_region
}


# resource "aws_vpc" "vpc1" {
#   cidr_block           = var.vpc_cidr_block
#   enable_dns_hostnames = var.enable_dns_hostnames
#   tags = merge(local.common_tags, { name = "${local.name_prefix}-vpc"
#   })
# }

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc1.id
#   tags   = merge(local.common_tags, { name = "${local.name_prefix}-ig" })
# }

data "aws_availability_zones" "available" {}

# resource "aws_subnet" "subnets" {
#   count             = var.vpc_subnet_count
#   vpc_id            = module.vpc.vpc_id
#   cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index)
#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   tags              = merge(local.common_tags, { name = "${local.name_prefix}-subnet-${count.index}" })
# }


# resource "aws_route_table" "rtb" {
#   vpc_id = aws_vpc.vpc1.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
# }

# resource "aws_route_table_association" "rta-subnets" {
#   count          = var.vpc_subnet_count
#   subnet_id      = aws_subnet.subnets[count.index].id
#   route_table_id = aws_route_table.rtb.id
# }



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.16.1"


  cidr           = var.vpc_cidr_block[terraform.workspace]
  azs            = slice(data.aws_availability_zones.available.names, 0, (var.vpc_subnet_count[terraform.workspace]))
  public_subnets = [for subnet in range(var.vpc_subnet_count[terraform.workspace]) : cidrsubnet(var.vpc_cidr_block[terraform.workspace], 8, subnet)]

  enable_nat_gateway      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-vpc" })
}


resource "aws_security_group" "instancesecuritygroup" {
  name   = "${local.name_prefix}-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = var.port.HTTP
    to_port     = var.port["HTTP"]
    protocol    = var.protocol[0]
    cidr_blocks = [var.vpc_cidr_block[terraform.workspace]]
  }
  ingress {
    from_port   = var.port["SSH"]
    to_port     = var.port.SSH
    protocol    = var.protocol[0]
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "keyname" {
  key_name   = "keyname-key"
  public_key = var.public_key
}

resource "aws_instance" "appinstance" {
  count                       = var.instance_count[terraform.workspace]
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.public_subnets[(count.index % var.vpc_subnet_count[terraform.workspace])]
  vpc_security_group_ids      = [aws_security_group.instancesecuritygroup.id]
  key_name                    = aws_key_pair.keyname.id
  associate_public_ip_address = true
  iam_instance_profile        = module.app_s3.instance_profile.name
  depends_on                  = [module.app_s3]


  user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = module.app_s3.web_bucket.id
  })

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-instance-${count.index}" })

}



# resource "aws_security_group" "RDSSesutitygroup" {
#   name   = "RDSSecuritygroup"
#   vpc_id = aws_vpc.vpc1.id
#   ingress {
#     from_port                 = var.port.RDS 
#     to_port                   = var.port["RDS"]
#     protocol                  = var.protocol[0]
#     security_groups = [aws_security_group.instancesecuritygroup.id]
#   }
# }

# resource "aws_db_subnet_group" "dbsubnetgroup" {
# name       = "dbsubnetgroup"
# subnet_ids = [aws_subnet.publicsubnet.id, aws_subnet.privatesubnet.id]
# }

# resource "aws_db_instance" "dbinstance" {
# allocated_storage     = 20
# db_name               = "postgres"
# engine                = var.RDSengine
# instance_class        = var.RDSinstance_class
# username              = var.username
# password              = var.password
# db_subnet_group_name  = aws_db_subnet_group.dbsubnetgroup.id
# publicly_accessible   = false
# skip_final_snapshot = true 
# vpc_security_group_ids = [aws_security_group.RDSSesutitygroup.id]
# tags = local.common_tags

# }



data "aws_elb_service_account" "root" {}




resource "aws_lb_target_group" "lbtargetgroup" {
  name     = "${local.name_prefix}-tg"
  port     = var.port.HTTP
  protocol = var.protocol[1]
  vpc_id   = module.vpc.vpc_id

  tags = local.common_tags
}
resource "aws_lb_target_group_attachment" "lbattach" {
  count            = var.instance_count[terraform.workspace]
  target_group_arn = aws_lb_target_group.lbtargetgroup.arn
  target_id        = aws_instance.appinstance[count.index].id
  port             = var.port.HTTP
}



resource "aws_lb" "lb" {
  name               = "${local.name_prefix}-lb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.instancesecuritygroup.id]
  subnets            = module.vpc.public_subnets
  ip_address_type    = var.ip_address_type
  tags               = local.common_tags

  access_logs {
    bucket  = module.app_s3.web_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.port.HTTP
  protocol          = var.protocol[1]
  default_action {
    type             = var.listener_type
    target_group_arn = aws_lb_target_group.lbtargetgroup.arn
  }
}
