variable "resource_name_prefix" {
  type = string
}

variable "event_bus_name" {
  description = "EventBridge bus name (default bus if null)"
  type        = string
  default     = null
}

variable "ec2_state_values" {
  description = "EC2 states to include"
  type        = list(string)
  default     = ["pending", "running", "stopping", "stopped", "shutting-down", "terminated"]
}

variable "instance_ids" {
  description = "Optional list of EC2 instance IDs to match; empty means all instances"
  type        = list(string)
  default     = []
}

variable "enable_when_no_instances" {
  description = "If true, create the rule even when no instance IDs are provided (will match all instances). Defaults to false to avoid catching everything when nothing opted in."
  type        = bool
  default     = false
}

variable "lambda_function_arn" {
  description = "Lambda ARN to invoke"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda name to grant permission"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
