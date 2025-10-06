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

module "prometheus_grafana_loki_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-prometheus-grafana-loki-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-prometheus-grafana-loki_-erver" })

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

module "ussd_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-ussd-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ussd-server" })

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

module "mcn_ivr_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-mcn-ivr-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-mcn-ivr-server" })

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
  vpc_id = var.vpc_id
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

module "smsc_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-smsc-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-smsc-server" })

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

module "scp_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-scp-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-scp-server" })

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

module "ocs_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-ocs-server"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-ocs-server" })

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

module "interface_endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-interface-endpoint"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-interface-endpoint" })

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