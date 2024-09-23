# data "aws_lb" "tech_lb" {
#     tags = {
#         "kubernetes.io/service-name" = "default/svc-loja"
#     }
# }

# output lb_output_arn {
#   value = data.aws_lb.tech_lb.arn
# }

# output lb_output_dns_name {
#   value = data.aws_lb.tech_lb.dns_name
# }


data "aws_lambda_function_url" "lambda_authorizer" {
  function_name = "lambda_loja_authorizer"
}

output lambda_authorizer {
  value = data.aws_lambda_function_url.lambda_authorizer
}

# resource "aws_api_gateway_vpc_link" "main" {
#   name        = "tech_vpclink_teste"
#   description = "Foobar Gateway VPC Link. Managed by Terraform."
#   target_arns = [data.aws_lb.tech_lb.arn]
# }

# resource "aws_api_gateway_rest_api" "main" {
#   name           = "tech_gateway"
#   description    = "Foobar Gateway VPC Link. Managed by Terraform."

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_method" "root" {
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   resource_id   = aws_api_gateway_rest_api.main.root_resource_id
#   http_method   = "ANY"
#   authorization = "NONE"

#   request_parameters = {
#     "method.request.path.proxy"           = true
#     "method.request.header.Authorization" = true
#   }
# }

# resource "aws_api_gateway_integration" "root" {
#   rest_api_id = aws_api_gateway_rest_api.main.id
#   resource_id = aws_api_gateway_rest_api.main.root_resource_id
#   http_method = "ANY"

#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = "http://${data.aws_lb.tech_lb.dns_name}/"
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
#   uri                     = "http://${data.aws_lb.tech_lb.dns_name}/{proxy}"
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

# resource "aws_api_gateway_stage" "stage_dev" {
#   deployment_id = aws_api_gateway_deployment.deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.main.id
#   stage_name    = "dev"
# }

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.main.id

#   triggers = {
#     redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main.body))
#     auto_deploy  = true
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   depends_on = [aws_api_gateway_integration.proxy, aws_api_gateway_integration.root]
# }

# output "base_url" {
#   value = "${aws_api_gateway_stage.stage_dev.invoke_url}/"
# }
