output "vpc_security_group_ids" {
    value = aws_security_group.nginx_sg.*.id
}

output "launch_template" {
value = aws_launch_template.ngnix_launch.*.id
}

output "vpc_id" {
  value = (module.VPC.*.vpc_id)
}

output "subnetA_id" {
   value = (module.VPC.*.subnetA_id)
}

output "subnetB_id" {
   value = (module.VPC.*.subnetB_id)
}

output "elb" {
  description = "The DNS name of the ELB"
  value       = aws_lb.ngnix_lb.dns_name
}

output "ngnix_web_ip" {
    value = aws_instance.ngnix_web.public_ip
}

# output "ngnix_id" {
#    value = aws_instance.ngnix_webserver.*.id
# }

output ip_of_instances_from_asg {
    value = data.aws_instances.test.ids
}
