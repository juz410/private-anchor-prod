resource "aws_vpc_endpoint" "mongodb_interface_endpoint" {
  vpc_id            = "vpc-0abd3fbc4e290d293"
  service_name      = "com.amazonaws.vpce.ap-southeast-5.vpce-svc-084302bd6762fb6cb"
  vpc_endpoint_type = "Interface"

  subnet_ids         = var.subnet_ids

  security_group_ids = var.security_group_ids   
  private_dns_enabled = false                  
  tags = merge(
    var.tags,
    { Name = "${var.resource_name_prefix}-mongodb-endpoint" }
  )
}
