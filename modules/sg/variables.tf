variable "security_groups" {
  type = map(object({
    name   = string
    vpc_id = string

    ingress = list(object({
      from_port = number
      to_port   = number
      protocol  = string
      cidr_blocks = list(string)
    }))

    egress = list(object({
      from_port = number
      to_port   = number
      protocol  = string
      cidr_blocks = list(string)
    }))
  }))
}
