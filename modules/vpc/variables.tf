variable "vpcs" {
  description = "VPC configuration map"
  type = map(object({
    cidr_block = string
    name       = string

    public_subnet_cidr  = string
    private_subnet_cidr = string
    az                   = string
  }))
}
