//output ecr {
//    description = "ECR URL"
//    value= module.ecr.repository_url
//}

output subnets {
    description = "Subnets"
    value = data.aws_subnets.subnets
}

output loadbalancer {
    value = aws_lb.app-LB.dns_name
}