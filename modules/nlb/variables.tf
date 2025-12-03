
#networking
variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "target_alb_arn" {
  type = string
}

# variable "ssl_cert_arn" {
#     type = string
# }

variable "lb_access_logs_bucket" {
  type = string
}

variable "current_account_id" {
  type = string
}



#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}