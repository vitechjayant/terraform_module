module "vpc" {
    source = "C:/Users/Jayant soni/OneDrive/Desktop/Terraform/AWS/module/vpc"
    
  vpc_cidr_range = {
      cidr_block = var.vpc_cidr_range
      name ="test"   
      }
    subnet_name_tags = {
        names = var.subnet_name_tags
    }
    region = {
      names = var.region
      
    }
    infra_bucket = {
        name = var.infra_bucket
    }
             
    db_subnets = {
        names = var.db_subnets

}
    
    public_subnets = {
        names = var.public_subnets

}  
    
    
}