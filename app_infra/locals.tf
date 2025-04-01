
locals {
  private_subnets = [
    for subnet in data.aws_subnet.subnets : subnet.id
    if can(regex("private_subnet.*", lower(subnet.tags["Name"])))
  ]

  public_subnet = [
    for subnet in data.aws_subnet.subnets : subnet.id
    if can(regex("public_subnet.*", lower(subnet.tags["Name"])))
  ]
}