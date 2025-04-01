# List of local variables used 

locals {
  vpc_tags = merge(
      var.tags, 
      {supported_regions = join (",", var.supported_regions)}
    )
}