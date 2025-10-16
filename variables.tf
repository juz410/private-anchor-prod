#regional
variable "region" {
  type    = string
  default = "ap-southeast-5"
}

#vpc vars
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "private_kalsym_app_subnet_a_cidr" {
  type = string
}

variable "private_kalsym_app_subnet_b_cidr" {
  type = string
}

variable "private_kalsym_ecs_subnet_a_cidr" {
  type = string
}

variable "private_kalsym_ecs_subnet_b_cidr" {
  type = string
}


variable "private_kalsym_db_subnet_a_cidr" {
  type = string
}

variable "private_kalsym_db_subnet_b_cidr" {
  type = string
}

variable "private_internal_alb_subnet_a_cidr" {
  type = string
}

variable "private_internal_alb_subnet_b_cidr" {
  type = string
}

variable "private_multibyte_subnet_a_cidr" {
  type = string
}

variable "private_multibyte_subnet_b_cidr" {
  type = string
}

variable "private_multibyte_db_subnet_a_cidr" {
  type = string
}

variable "private_multibyte_db_subnet_b_cidr" {
  type = string
}

variable "private_tgw_subnet_a_cidr" {
  type = string
}

variable "private_tgw_subnet_b_cidr" {
  type = string
}

#tgw
variable "tgw_id" {
  type = string
}


#tagging vars
# variable "resource_name_prefix" {
#   type = string
# }

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "project_id" {
  type = string
}


variable "owner" {
  type = string
}

# variable "cost_center" {
#   type = string
# }