variable "instances" {
  type = map(object({
    name                 = string
    ami_id               = string
    subnet_id            = string
    public_ip_enabled    = bool
    security_group_ids   = list(string)
    iam_instance_profile = string
    user_data            = optional(string)
    key_name             = optional(string) # optional override
  }))
}

variable "instance_type" {
  type = string
}
