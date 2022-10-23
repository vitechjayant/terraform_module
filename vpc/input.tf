# Varible define 
variable "region" {
  type = object({
    names = string
  })

}
variable "vpc_cidr_range" {
    type = object({
        name=string
        cidr_block=string

    })
    description = "(optional) describe your variable"
}


variable "public_subnets" {
  type = object({
    names = list(string)
  })

}
variable "db_subnets" {
  type = object({
    names = list(string)
  })

}
variable "subnet_name_tags" {
  type = object({
    names = list(string)
  })

}
variable "infra_bucket" {
  type = object({
    name = string
  })
}