module "external_nlb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  name    = "${var.resource_name_prefix}-sg-external_nlb"
  vpc_id  = var.vpc_id
  tags    = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-external_nlb" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9085
      to_port     = 9085
      protocol    = "tcp"
      description = "Allow HTTP 9085  traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}


module "external_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-external-alb"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-external-alb" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9085
      to_port     = 9085
      protocol    = "tcp"
      description = "Allow HTTP 9085  traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "prometheus_grafana_loki_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-prometheus-grafana-loki-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-prometheus-grafana-loki-server" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 3100
      to_port     = 3100
      protocol    = "tcp"
      description = "Allow 3100 Alloy from all main vpc services"
      cidr_blocks = var.main_vpc_cidr
    },
    {
      from_port   = 3100
      to_port     = 3100
      protocol    = "tcp"
      description = "Allow 3100 Alloy from all hk vpc services"
      cidr_blocks = var.hk_vpc_cidr
    },
    {
      from_port   = 3100
      to_port     = 3100
      protocol    = "tcp"
      description = "Allow 3100 Alloy from all testbed vpc services"
      cidr_blocks = var.testbed_vpc_cidr
    },
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      description = "Allow 3000 from all testbed vpc services"
      cidr_blocks = var.testbed_vpc_cidr
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "Allow 9090 from all testbed vpc services"
      cidr_blocks = var.testbed_vpc_cidr
    },
    {
      from_port   = 9093
      to_port     = 9093
      protocol    = "tcp"
      description = "Allow 9093 from all testbed vpc services"
      cidr_blocks = var.testbed_vpc_cidr
    },
    {
      from_port   = 12345
      to_port     = 12345
      protocol    = "tcp"
      description = "Allow 12345 from all testbed vpc services"
      cidr_blocks = var.testbed_vpc_cidr
    }
  ]

  ingress_with_source_security_group_id = [
    #TEMP
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Allow 3000 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 9090
      to_port                  = 9090
      protocol                 = "tcp"
      description              = "Allow 9090 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 9093
      to_port                  = 9093
      protocol                 = "tcp"
      description              = "Allow 9093 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 12345
      to_port                  = 12345
      protocol                 = "tcp"
      description              = "Allow 12345 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Allow 3000 from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 9090
      to_port                  = 9090
      protocol                 = "tcp"
      description              = "Allow 9090 from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 9093
      to_port                  = 9093
      protocol                 = "tcp"
      description              = "Allow 9093 from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 12345
      to_port                  = 12345
      protocol                 = "tcp"
      description              = "Allow 12345 from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    # {
    #   from_port                = 22
    #   to_port                  = 22
    #   protocol                 = "tcp"
    #   description              = "Allow SSH from multibyte jumphost"
    #   source_security_group_id = "sg-02f00e396c23d46e4"
    # }
    # {
    #   from_port                = 9090
    #   to_port                  = 9090
    #   protocol                 = "tcp"
    #   description              = "Allow 9090 from smsc server"
    #   source_security_group_id = module.smsc_server_sg.security_group_id
    # },
    # {
    #   from_port                = 3100
    #   to_port                  = 3100
    #   protocol                 = "tcp"
    #   description              = "Allow 3100 from smsc server"
    #   source_security_group_id = module.smsc_server_sg.security_group_id
    # },


  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# locals {
#   ussd_on_prem_ips = [
#     "10.33.10.16",
#     "10.33.10.17",
#     "10.100.54.8",
#     "10.100.54.9",
#     "123.136.104.240",
#     "123.136.104.241",
#     "123.136.110.148",
#     "123.136.110.149"
#   ]
# }

module "ussd_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-ussd-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ussd-server" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 11000
      to_port     = 11000
      protocol    = "tcp"
      description = "Allow SMPP 11000 traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_a_cidr
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow SMPP 11000 traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_b_cidr
    },
    {
      from_port   = 11001
      to_port     = 11001
      protocol    = "tcp"
      description = "Allow HTTP 11001 traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_a_cidr
    },
    {
      from_port   = 11001
      to_port     = 11001
      protocol    = "tcp"
      description = "Allow HTTP 11001 traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_b_cidr
    }
  ]


  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "ALB HTTP"
      source_security_group_id = module.external_alb_sg.security_group_id
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow USSD Menu DB 3306 from self"
      source_security_group_id = module.ussd_server_sg.security_group_id
    },
    {
      from_port                = 11000
      to_port                  = 11000
      protocol                 = "tcp"
      description              = "Allow SMNP 11000 from mcn ivr"
      source_security_group_id = module.mcn_ivr_server_sg.security_group_id
    },
    {
      from_port                = 11000
      to_port                  = 11000
      protocol                 = "tcp"
      description              = "Allow SMNP 11000 from prometheous"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },



    {
      from_port                = 11001
      to_port                  = 11001
      protocol                 = "tcp"
      description              = "Allow SMNP 11001 from mcn ivr"
      source_security_group_id = module.mcn_ivr_server_sg.security_group_id
    },
    {
      from_port                = 11001
      to_port                  = 11001
      protocol                 = "tcp"
      description              = "Allow SMNP 11001 from prometheous"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },


    {
      from_port                = 8773
      to_port                  = 8773
      protocol                 = "tcp"
      description              = "Allow HTTP 8773 from prometheous"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ussd_server_sg.security_group_id
    },
    {
      from_port                = 8773
      to_port                  = 8773
      protocol                 = "tcp"
      description              = "Allow HTTP 8773 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },


  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# locals {
#   mcn_ivr_on_prem_ips = [
#     "10.33.10.112",
#     "10.33.10.113",
#     "10.100.54.18",
#     "10.100.54.19",
#     "10.33.10.9",
#     "10.33.10.10",
#     "10.33.10.11",
#     "10.33.10.12",
#     "10.100.54.129",
#     "10.100.54.130",
#     "10.100.54.133",
#     "10.100.54.134",
#     "10.33.26.168",
#     "10.33.26.169",
#     "10.100.56.156",
#     "10.100.56.157"
#   ]
# }
module "mcn_ivr_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-mcn-ivr-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-mcn-ivr-server" })

  ingress_with_cidr_blocks = [

  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },

    {
      from_port                = 9626
      to_port                  = 9626
      protocol                 = "tcp"
      description              = "Allow HTTP 9626 from prometheus"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.mcn_ivr_server_sg.security_group_id
    },
    {
      from_port                = 9626
      to_port                  = 9626
      protocol                 = "tcp"
      description              = "Allow HTTP 9626 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ecs_fargate_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "kalsym_mysql_db_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-kalsym-mysql-db-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-kalsym-mysql-db-server" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_a_cidr
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Allow MySQL traffic from ecs services subnet"
      cidr_blocks = var.private_kalsym_ecs_subnet_b_cidr
    }
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow mysql from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MNP ECS Fargate service"
      source_security_group_id = module.ecs_fargate_mnp_sg.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow Product ECS Fargate service"
      source_security_group_id = module.ecs_fargate_product_sg.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow USSD Servers"
      source_security_group_id = module.ussd_server_sg.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow MCN IVR Servers"
      source_security_group_id = module.mcn_ivr_server_sg.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow Prometheus Servers"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.kalsym_mysql_db_server_sg.security_group_id
    }



  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "internal_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-internal-alb"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-internal-alb" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "iot_web_frontend_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-iot-web-frontend-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-iot-web-frontend-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [

    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow HTTP 8080 from internal ALB"
      source_security_group_id = module.internal_alb_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow HTTP 8080 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    # {
    #   from_port                = 8080
    #   to_port                  = 8080
    #   protocol                 = "tcp"
    #   description              = "Allow 8080 HTTP from eastel jumphost"
    #   source_security_group_id = "sg-0247a03b9b047bddc"
    # },

  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "iot_web_backend_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-iot-web-backend-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-iot-web-backend-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.iot_web_backend_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },


  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "middleware_api_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-middleware-api-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-middleware-api-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.middleware_api_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot backend"
      source_security_group_id = module.iot_web_backend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot backend"
      source_security_group_id = module.iot_web_backend_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from smsc"
      source_security_group_id = module.smsc_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from smsc"
      source_security_group_id = module.smsc_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "dra_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-dra-server"
  vpc_id = var.vpc_hk_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-dra-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.dra_server_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# locals {
#   smsc_on_prem_ips = [
#     "10.33.10.16",
#     "10.33.10.17",
#     "10.100.54.8",
#     "10.100.54.9",
#     "123.136.104.240",
#     "123.136.104.241",
#     "123.136.110.148",
#     "123.136.110.149"
#   ]
# }

module "smsc_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-smsc-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-smsc-server" })

  ingress_with_cidr_blocks = [

  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 5016
      to_port                  = 5016
      protocol                 = "tcp"
      description              = "Allow SMPP 5016 Middleware API Server"
      source_security_group_id = module.middleware_api_server_sg.security_group_id
    },
    {
      from_port                = 5016
      to_port                  = 5016
      protocol                 = "tcp"
      description              = "Allow SMPP 5016 USSDC Server"
      source_security_group_id = module.ussd_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.smsc_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
# locals {
#   scp_on_prem_ips = [
#     "10.33.10.16",
#     "10.33.10.17",
#     "10.100.54.8",
#     "10.100.54.9",
#     "123.136.104.240",
#     "123.136.104.241",
#     "123.136.110.148",
#     "123.136.110.149"
#   ]
# }

module "scp_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-scp-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-scp-server" })

  ingress_with_cidr_blocks = [

  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.scp_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

# locals {
#   ocs_on_prem_ips = [
#     "10.44.150.28", "10.44.150.29", "10.44.150.30", "10.44.150.31",
#     "10.44.150.8",  "10.44.150.9",  "10.44.150.10", "10.44.150.11",
#     "10.102.58.16", "10.102.58.17", "10.102.58.18", "10.102.58.19",
#     "10.44.150.68", "10.44.150.69", "10.44.150.70", "10.44.150.71",
#     "10.44.150.84", "10.44.150.85", "10.44.150.86", "10.44.150.87",
#     "10.102.58.44", "10.102.58.45", "10.102.58.46", "10.102.58.47"
#   ]
# }

module "ocs_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-ocs-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ocs-server" })

  ingress_with_cidr_blocks = [

  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 80
    #   to_port                  = 80
    #   protocol                 = "tcp"
    #   description              = "Allow HTTP from external ALB"
    #   source_security_group_id = module.external_alb_sg.security_group_id
    # }
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 20072
      to_port                  = 20072
      protocol                 = "tcp"
      description              = "Allow Diameter 20072 SMSC Server"
      source_security_group_id = module.smsc_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ocs_server_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 9993
      to_port                  = 9993
      protocol                 = "tcp"
      description              = "Allow HTTPS 9993 from iot frontend"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      description              = "Allow 8080 HTTP from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "multibyte_postgresql_db_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-multibyte-postgresql-db-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-multibyte-postgresql-db-server" })

  ingress_with_cidr_blocks = [
    # {
    #   from_port   = 80
    #   to_port     = 80
    #   protocol    = "tcp"
    #   description = "Allow HTTP traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # },
    # {
    #   from_port   = 443
    #   to_port     = 443
    #   protocol    = "tcp"
    #   description = "Allow HTTPS traffic from anywhere"
    #   cidr_blocks = "0.0.0.0/0"
    # }
  ]

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 5432
    #   to_port                  = 5432
    #   protocol                 = "tcp"
    #   description              = "Allow PostgreSQL Connection"
    #   source_security_group_id = module.ocs_server_sg.security_group_id
    # },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow postgresql from multibyte jumphost"
      source_security_group_id = "sg-02f00e396c23d46e4"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow postgresql from eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow SCP Servers"
      source_security_group_id = module.scp_server_sg.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow OCS Servers"
      source_security_group_id = module.ocs_server_sg.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow IOT Backend Servers"
      source_security_group_id = module.iot_web_backend_server_sg.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow IOT Frontend Servers"
      source_security_group_id = module.iot_web_frontend_server_sg.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "Allow Middleware API Servers"
      source_security_group_id = module.middleware_api_server_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.multibyte_postgresql_db_server_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "interface_endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-interface-endpoint"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-interface-endpoint" })

  ingress_with_source_security_group_id = [

  ]

  ingress_with_cidr_blocks = [

    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS Traffic from the VPC"
      cidr_blocks = "10.100.4.0/22"
    }
  ]



  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "mongodb_endpoint_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for mongodb"

  name   = "${var.resource_name_prefix}-sg-mongodb-endpoint"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-mongodb-endpoint" })

  ingress_with_source_security_group_id = [
    # {
    #   from_port                = 443
    #   to_port                  = 443
    #   protocol                 = "tcp"
    #   description              = "Allow HTTPS traffic from UAT servers"
    #   source_security_group_id = module.uat_server_sg.security_group_id
    # },
    # {
    #   from_port                = 443
    #   to_port                  = 443
    #   protocol                 = "tcp"
    #   description              = "Allow HTTPS traffic from All-in-One servers"
    #   source_security_group_id = module.all_in_one_server_sg.security_group_id
    # }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

#FARGATE SERVICES SG

module "ecs_fargate_api_gateway_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate api gateway"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-api-gateway"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-api-gateway" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 8222
      to_port                  = 8222
      protocol                 = "tcp"
      description              = "Allow HTTP 8222 from external ALB"
      source_security_group_id = module.external_alb_sg.security_group_id
    },
    {
      from_port                = 8443
      to_port                  = 8443
      protocol                 = "tcp"
      description              = "Allow HTTPS 8443 from external ALB"
      source_security_group_id = module.external_alb_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_api_gateway_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ecs_fargate_asset_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate asset"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-asset"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-asset" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_asset_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow all outbound traffic"
    cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_communication_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate communication"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-communication"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-communication" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_communication_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_discount_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate discount"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-discount"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-discount" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_discount_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_discovery_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate discovery"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-discovery"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-discovery" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_discovery_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_membership_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate membership"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-membership"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-membership" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_membership_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_mnp_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate mnp"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-mnp"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-mnp" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 9085
      to_port                  = 9085
      protocol                 = "tcp"
      description              = "Allow HTTP 9085 from external ALB"
      source_security_group_id = module.external_alb_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_mnp_sg.security_group_id
    }

  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_order_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate order"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-order"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-order" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_order_sg.security_group_id
    }

  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_organization_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate organization"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-organization"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-organization" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_organization_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_payment_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate payment"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-payment"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-payment" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_payment_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_product_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate product"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-product"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-product" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_product_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_provisioning_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate provisioning"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-provisioning"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-provisioning" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 8090
      to_port                  = 8090
      protocol                 = "tcp"
      description              = "Allow HTTP 8090 from internal ALB"
      source_security_group_id = module.internal_alb_sg.security_group_id
    },
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_provisioning_sg.security_group_id
    }

  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_reporting_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate reporting"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-reporting"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-reporting" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_reporting_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_telco_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate telco"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-telco"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-telco" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_telco_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_transaction_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate transaction"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-transaction"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-transaction" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_transaction_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_user_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate user"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-user"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-user" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_user_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_rabbit_mq_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate user"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-rabbit-mq"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-rabbit-mq" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_rabbit_mq_sg.security_group_id
    },
    {
      from_port                = 15672
      to_port                  = 15672
      protocol                 = "tcp"
      description              = "Allow http 15672 from prometheous"
      source_security_group_id = module.prometheus_grafana_loki_server_sg.security_group_id
    },
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_fargate_alloy_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for ecs fargate user"

  name   = "${var.resource_name_prefix}-sg-ecs-fargate-alloy"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-fargate-alloy" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_fargate_alloy_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}


module "efs_rabbit_mq_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for efs rabbit mq storage"

  name   = "${var.resource_name_prefix}-sg-efs-rabbit-mq"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-efs-rabbit-mq" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.efs_rabbit_mq_sg.security_group_id
    },
    {
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      description              = "Allow 2049 Rabbit MQ Protocol From Self"
      source_security_group_id = module.ecs_fargate_rabbit_mq_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "sftp_server_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for sftp server"

  name   = "${var.resource_name_prefix}-sg-sftp-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-sftp-server" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.sftp_server_sg.security_group_id
    },
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Allow SSH From eastel jumphost"
      source_security_group_id = "sg-0247a03b9b047bddc"
    },
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}

module "ecs_ec2_webserver_server_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5.0"
  description = "SG for webserver in ecs subnet"

  name   = "${var.resource_name_prefix}-sg-ecs-ec2-webserver-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ecs-ec2-webserver-server" })

  ingress_with_source_security_group_id = [

    {
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      description              = "Allow Everything From Self"
      source_security_group_id = module.ecs_ec2_webserver_server_sg.security_group_id
    },
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "ALB HTTP"
      source_security_group_id = module.external_alb_sg.security_group_id
    },
    # {
    #   from_port                = 22
    #   to_port                  = 22
    #   protocol                 = "tcp"
    #   description              = "Allow SSH From eastel jumphost"
    #   source_security_group_id = "sg-0247a03b9b047bddc"
    # },
  ]
  egress_with_cidr_blocks = [{
    from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound traffic", cidr_blocks = "0.0.0.0/0"
  }]
}