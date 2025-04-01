	
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}