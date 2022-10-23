resource "aws_vpc" "AWS-VPC" {
  cidr_block = var.vpc_cidr_range.cidr_block
  tags = {
    Name = var.vpc_cidr_range.name
  }

}

resource "aws_s3_bucket" "infra_bucket" {
  bucket = var.infra_bucket.name

  tags = {
    Name        = "AWS_infrabucket"
    Environment = "Dev"
  }
}

# Creating Subnet under AWS-VPC web1 and web2 (2 subnets)
resource "aws_subnet" "subnets" {
  count      = length(var.subnet_name_tags.names)
  cidr_block = cidrsubnet(var.vpc_cidr_range.cidr_block, 8, count.index)
  tags = {
    Name = var.subnet_name_tags.names[count.index]
  }
  availability_zone = format("${var.region.names}%s", count.index % 2 == 0 ? "a" : "b")
  vpc_id            = aws_vpc.AWS-VPC.id

}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.AWS-VPC.id

  tags = {
    Name = "AWS-VPC_GW"
  }
}

resource "aws_security_group" "websecurity" {
  name        = "websecurity"
  vpc_id      = aws_vpc.AWS-VPC.id
  description = "Created by terraform"
  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  ingress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  egress {
    from_port        = local.all_ports
    to_port          = local.all_ports
    protocol         = local.any_protocol
    cidr_blocks      = [local.any_where]
    ipv6_cidr_blocks = [local.any_where_ip6]
  }
  tags = {
    Name = "Web Security"
  }

}

resource "aws_security_group" "dbsecurity" {
  name        = "dbsecurity"
  vpc_id      = aws_vpc.AWS-VPC.id
  description = "Created by terraform"
  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  ingress {
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  egress {
    from_port        = local.all_ports
    to_port          = local.all_ports
    protocol         = local.any_protocol
    cidr_blocks      = [local.any_where]
    ipv6_cidr_blocks = [local.any_where_ip6]
  }
  tags = {
    Name = "DB Security"
  }

}

resource "aws_security_group" "appsecurity" {
  name        = "appsecurity"
  vpc_id      = aws_vpc.AWS-VPC.id
  description = "Created by terraform App"
  ingress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  ingress {
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp
    cidr_blocks = [local.any_where]
  }
  egress {
    from_port        = local.all_ports
    to_port          = local.all_ports
    protocol         = local.any_protocol
    cidr_blocks      = [local.any_where]
    ipv6_cidr_blocks = [local.any_where_ip6]
  }
  tags = {
    Name = "App Security"
  }

}

resource "aws_route_table" "routepublic" {
  vpc_id = aws_vpc.AWS-VPC.id

  route {
    cidr_block = local.any_where
    gateway_id = aws_internet_gateway.gw.id


  }
  tags = {
    Name = "Public route table"
  }
}
resource "aws_route_table" "routeprivate" {

  vpc_id = aws_vpc.AWS-VPC.id


  tags = {
    Name = "Private Route table"
  }
}

#subnet associations

resource "aws_route_table_association" "associations" {
  count          = length(aws_subnet.subnets)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = contains(var.public_subnets.names, lookup(aws_subnet.subnets[count.index].tags_all, "Name", "")) ? aws_route_table.routepublic.id : aws_route_table.routeprivate.id
}