data "aws_lb" "tech" {
#    filter {
#     name = "tag:kubernetes.io/service-name"
#     values = ["default/svc-loja"]
#    }
    most_recent = true
}

output "load_balancer_arn" {
    value = data.aws_lb.tech.arn
}

output "load_balancer_dns" {
    value = data.aws_lb.tech.dns
}