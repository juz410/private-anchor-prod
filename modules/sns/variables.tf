variable "topics" {
  description = "SNS topics to create"
  type = map(object({
    name         = string
    display_name = optional(string)
    subscriptions = optional(list(object({
      protocol = string # e.g. email
      endpoint = string # e.g. team.iaas+client@g-asiapac.com
    })), [])
    tags = optional(map(string), {})
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
