output "vpc_security_group_ids" {
  value = (module.LT.*.vpc_security_group_ids)
}

output "Launch_Template" {
  value = (module.LT.*.launch_template)
}

output "vpc_id" {
  value = (module.LT.*.vpc_id)
}

output "subnetA_id" {
   value = (module.LT.*.subnetA_id)
}

output "subnetB_id" {
   value = (module.LT.*.subnetB_id)
}

output "elb" {
    value = (module.LT.*.elb)
}

output "ngnix_web_ip" {
    value = (module.LT.*.ngnix_web_ip)
}

output ip_of_instances_from_asg {
    value = (module.LT.*.ip_of_instances_from_asg)
}
# output "ngnix_id" {
#   value = (module.LT.*.ngnix_id)
# }