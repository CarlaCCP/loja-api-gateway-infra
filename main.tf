data "aws_lb" "tech" {
    tags = {
        name = "kubernetes.io/service-name"
        value = "default/svc-loja"
    }
}

output "load_balancer_arn" {
    value = data.aws_lb.tech.arn
}

output "load_balancer_dns" {
    value = data.aws_lb.tech.name
}


# resource “aws_api_gateway_vpc_link” “main” {
#  name = “tech_vpclink”
#  description = “Foobar Gateway VPC Link. Managed by Terraform.”
#  target_arns = load_balancer_arn
# }

# resource “aws_api_gateway_rest_api” “main” {
#  name = "tech_gateway"
#  description = “Foobar Gateway used for EKS. Managed by Terraform.”
#  endpoint_configuration {
#    types = ["REGIONAL"]
#  }
# }

# resource "aws_api_gateway_resource" "proxy" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   parent_id   = aws_api_gateway_rest_api.main.root_resource_id
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "proxy" {
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   resource_id   = aws_api_gateway_resource.proxy.id
#   http_method   = "ANY"
#   authorization = "NONE"

#   request_parameters = {
#     "method.request.path.proxy"           = true
#     "method.request.header.Authorization" = true
#   }
# }

# resource "aws_api_gateway_integration" "proxy" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   resource_id = aws_api_gateway_resource.proxy.id
#   http_method = "ANY"

#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = "http://${load_balancer_dns}/{proxy}"
#   passthrough_behavior    = "WHEN_NO_MATCH"
#   content_handling        = "CONVERT_TO_TEXT"

#   request_parameters = {
#     "integration.request.path.proxy"           = "method.request.path.proxy"
#     "integration.request.header.Accept"        = "'application/json'"
#     "integration.request.header.Authorization" = "method.request.header.Authorization"
#   }

#   connection_type = "VPC_LINK"
#   connection_id   = aws_api_gateway_vpc_link.main.id
# }