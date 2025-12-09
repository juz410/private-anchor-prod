variable "resource_name_prefix" { type = string }

variable "instances" {
  description = "Instances to alarm on"
  type = map(object({
    instance_id   = string
    instance_name = string
    # keep instance_type optional; only use it if your CWAgent metrics really include it
    instance_type = optional(string)

    # Disk targets MUST match CWAgent dimensions for disk metrics
    disk_targets = optional(list(object({
      path   = string           # e.g. "/", "/apps"
      device = string           # e.g. "nvme0n1p1"
      fstype = string           # e.g. "xfs", "ext4"
      label  = optional(string) # e.g. "/dev/sda1" for naming
    })), [])
  }))
}

variable "sns_topics" {
  description = "SNS topic ARNs used by alarms"
  type = object({
    cpu         = string
    memory      = string
    statuscheck = string
    disk        = string
  })
}

variable "period_seconds" {
  type    = number
  default = 300
}

variable "evaluation_periods" {
  type    = number
  default = 1
}

variable "cpu_thresholds" {
  type    = list(number)
  default = [80, 90]
}

variable "memory_thresholds" {
  type    = list(number)
  default = [80, 90]
}

# “Low-10% / Low-5% free” -> “>=90 / >=95 used”
variable "disk_free_percent_thresholds" {
  type    = list(number)
  default = [10, 5]
}

# “Left-15GB / Left-10GB” using disk_free (Bytes)
variable "disk_free_gb_thresholds" {
  type    = list(number)
  default = [15, 10]
}

variable "cwagent_namespace" {
  type    = string
  default = "CWAgent"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "treat_missing_data" {
  description = "Recommended 'missing' especially for status checks"
  type        = string
  default     = "missing"
}
