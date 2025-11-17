variable "vpc_id" {
  type = string
}

variable "vpc_hk_id"{
  type = string
}

#ecr_cidr
variable "private_kalsym_ecs_subnet_a_cidr"{
  type = string
}

variable "private_kalsym_ecs_subnet_b_cidr" {
  type = string
}

variable "main_vpc_cidr"{
  type = string
}

variable "hk_vpc_cidr" {
  type = string
}

variable "testbed_vpc_cidr" {
  type = string
}

#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}