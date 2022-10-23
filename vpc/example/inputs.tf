# Varible define 
variable "region" {
    type    = string
    
}
variable "vpc_cidr_range" {
    type        = string
    
    description = "cidr range of AWS-VPC"
}

variable "public_subnets" {
    type = list(string)
    
}
variable "db_subnets" {
    type = list(string)
    
}
variable "subnet_name_tags" {
    type    = list(string)
    
}
variable "infra_bucket" {
    type = string
}