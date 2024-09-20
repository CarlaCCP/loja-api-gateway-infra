data "aws_lbs" "tech_lbs" {
    tags = {
        "kubernetes.io/service-name" = "default/svc-loja"
    }
}

data "aws_lb" "tech_lb" {
    tags = {
        "kubernetes.io/service-name" = "default/svc-loja"
    }
}
# data "aws_elb" "tech_elb" {
#       tags = {
#         "kubernetes.io/service-name" = "default/svc-loja"
#     }
# }

# output elb_output {
#   # value = data.aws_subnets.tech_subnetes.ids
#   value = data.tech_elb
# }

output lbs_output {
  # value = data.aws_subnets.tech_subnetes.ids
  value = data.tech_elb
}

output lb_output {
  # value = data.aws_subnets.tech_subnetes.ids
  value = data.tech_lb
}

resource "aws_api_gateway_vpc_link" "main" {
  name        = "tech_vpclink_teste"
  description = "Foobar Gateway VPC Link. Managed by Terraform."
  target_arns = data.aws_lbs.tech_lbs.arns
}

resource "aws_api_gateway_rest_api" "main" {
  name           = "tech_gateway"
  description    = "Foobar Gateway VPC Link. Managed by Terraform."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "root" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://a2e8081d793fc4d8abaeea9dc4112fb7-aacd053f04726e2f.elb.us-east-1.amazonaws.com/"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Accept"        = "'application/json'"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main.id
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://a2e8081d793fc4d8abaeea9dc4112fb7-aacd053f04726e2f.elb.us-east-1.amazonaws.com/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    "integration.request.header.Accept"        = "'application/json'"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main.id
}

resource "aws_api_gateway_stage" "stage_dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "dev"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main.body))
    auto_deploy  = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.proxy, aws_api_gateway_integration.root]
}

output "base_url" {
  value = "${aws_api_gateway_stage.stage_dev.invoke_url}/"
}