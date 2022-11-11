module "VPC" {
  source = "../VPC"
}

module "IAM" {
  source = "../IAM"
}
resource "tls_private_key" "ngnix_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  instance = [{
    name = "instance1"
    },
    {
      name = "instance2"
    },
    {
      name = "instance3"
  }]
}


# locals {
#  tag_specifications = {
#    "instance" = { resource_type = "instance", tags = "instance1" },
#    "instance" = { resource_type = "instance", tags = "instance2" },
#    "instance" = { resource_type = "instance", tags = "instance3" },
# }
# }

resource "aws_key_pair" "generated_key" {
  key_name   = "ngnix_key"
  public_key = tls_private_key.ngnix_key.public_key_openssh
}

# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

resource "aws_security_group" "nginx_sg" {
  name        = "ngnix_sg1"
  description = "Allow inbound traffic"
  vpc_id      = module.VPC.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   # cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
   #cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ngnix-sg"
  }
}

resource "aws_instance" "ngnix_web" {
  ami           = "ami-08d82213ea12bb4b9"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "ngnix_key"
  subnet_id                   = module.VPC.subnetA_id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]

  tags = {
    "Name" = "ngnix_web"
  }

}

# resource "aws_instance" "ngnix_webserver" {
#    instance_type          = "t2.micro"
#    ami                    = "ami-03f6d497fceb40069"
#    key_name               = "ngnix_key"
#    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
#    subnet_id              = module.VPC.subnetA_id
#    #user_data              = "${file("/home/einfochips/Desktop/terraform-ec2/scripts/init.sh")}"
  
#    tags = {
#        Name = "ngnix-preinstalled"
#    }

#    connection {
#   type = "ssh"
#   script_path = "/home/einfochips/Desktop/terraform-ec2/scripts/init.sh"
# }

# }

resource "aws_launch_template" "ngnix_launch" {
  
  name_prefix   = "ngnix_launch"
  image_id      = "ami-08d82213ea12bb4b9"
  instance_type = "t2.micro"

    iam_instance_profile {
    arn = module.IAM.aws_iam_instance_profile_arn
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

key_name = "ngnix_key"

#   tag_specifications {
#     resource_type = "instance"
#     tags = {
#       Name_prefix = "i1"   
#       Source = "Autoscaling"
#     }
#   }
# }

#  user_data = filebase64("/home/einfochips/Desktop/terraform-ec2/LT/user_data.sh")



#   tags = merge(
#     var.tag_specifications,
#     {
#       Name = "instance"
#       Source = "Autoscaling"
#     },
#   )
# }

#   dynamic "tag_specifications" {
#     for_each = local.tag_specifications
#     content {
#       for_each = local.tag_specifications
#       # count = length(var.tag_specifications)
#       resource_type = each.key
#       tags          = each.value
#     }
#   }
# }
#   tag_specifications {
#   resource_type = "instance"
#   tags = { 
#     { 
#       key = "Name_prefix"
#       value = "instance"
#       propagate_at_launch = true 
#       }
#     }
# }
#  }

#     tags = {
#     Name_prefix = "instance"
#     }
# }

#  dynamic "tag_specifications" {
#     for_each = data.aws_default_tags.current.tags
#     content {
#       key                 = tag.key
#       value               = tag.value
#       propagate_at_launch = true
#     }

# }

#   tag_specifications {
#     resource_type = "instance"
#     tags = ( 
#     {
#       "key" = "Name"
#       "value" = "i1"
#       "propagate_at_launch" = true
#     },
#     {
#       "key" = "Name"
#       "value" = "i2"
#       "propagate_at_launch" = true
#     },
#     {
#       "key" = "Name"
#       "value" = "i3"
#       "propagate_at_launch" = true
#     },
    
#     )
#  }
}

  # tag_specifications {
  #   resource_type = "instance"
  #   tags          = "i1"
  # }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags          = "i2"
  # }

  # tag_specifications {
  #   resource_type = "instance"
  #   tags          = "i3"
  # }
  

resource "aws_lb_target_group" "ngnix_tg" {
  name     = "ngnix-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id      = module.VPC.vpc_id
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

resource "aws_lb" "ngnix_lb" {
  name               = "ngnix-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets = [module.VPC.subnetA_id, module.VPC.subnetB_id]


}

resource "aws_lb_target_group_attachment" "ngnix_tg_attach" {
  target_group_arn = aws_lb_target_group.ngnix_tg.arn
  target_id        = aws_instance.ngnix_web.id
  port             = 80

    depends_on = [
    aws_lb.ngnix_lb
  ]
}

resource "aws_lb_listener" "lb_listener_http" {
   load_balancer_arn    = aws_lb.ngnix_lb.id
   port                 = 80
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.ngnix_tg.arn
    type             = "forward"
  }
}

# data "aws_default_tags" "current" {
# tags = concat(
#     {
#       "key" = "Name"
#       "value" = "i1"
#       "propagate_at_launch" = true
#     },
#     {
#       "key" = "Name"
#       "value" = "i2"
#       "propagate_at_launch" = true
#     },
#     {
#       "key" = "Name"
#       "value" = "i3"
#       "propagate_at_launch" = true
#     },
#   var.tags
# )

# locals {
#   instances = toset([
#     "instance1",
#     "instance2",
#     "instance3",
#   ])


resource "aws_autoscaling_group" "ngnix_asg" {
  vpc_zone_identifier = [module.VPC.subnetA_id, module.VPC.subnetB_id]
  name_prefix = "ngnix_asg"
  desired_capacity   = 2
  max_size           = 6
  min_size           = 1
  health_check_grace_period = 60
  health_check_type         = "EC2"
  target_group_arns         = ["${aws_lb_target_group.ngnix_tg.arn}"]



  launch_template {
    id      = aws_launch_template.ngnix_launch.id
    version = "$Latest"
  }


  initial_lifecycle_hook {
    name                    = "lifecycle-launching"
    default_result          = "ABANDON"
    heartbeat_timeout       = 1000
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
    notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }

  initial_lifecycle_hook {
    name                    = "lifecycle-terminating"
    default_result          = "ABANDON"
    heartbeat_timeout       = 1000
    lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
    notification_target_arn = module.autoscale_dns.autoscale_handling_sns_topic_arn
    role_arn                = module.autoscale_dns.agent_lifecycle_iam_role_arn
  }

  # tag {
  #   key                 = "asg:hostname_pattern"
  #   value               = "#instanceid.asg-handler-vpc.testing@${aws_route53_zone.main.id}"
  #   propagate_at_launch = true
  # }

#     dynamic "tag" {
#     for_each = toset( ["2", "3", "4"] )

#     content {
#       key = "Name"
#       value = tag.key == "0" ? "instance1" : "instance${tag.key}"
#       propagate_at_launch = true
#     }
# }

  # tags = concat(
  #   {
  #     {
  #       key                 = "Name"
  #       value               = "instance1"
  #       propagate_at_launch = true
  #     },
  #   },
  #   var.tags,
  #   local.instances,
  # )

}

module "autoscale_dns" {
  source  = "meltwater/asg-dns-handler/aws"
  version = "2.1.7"

  autoscale_handler_unique_identifier = "my_ngnix_asg_handler"
  autoscale_route53zone_arn           = aws_route53_zone.main.arn
  vpc_name                            = var.vpc_name
}

resource "aws_route53_zone" "main" {
#  name = aws_lb.ngnix_lb.zone_id
  name          = "asg-handler-vpc.testing"
  force_destroy = true

  vpc {
    vpc_id      = module.VPC.vpc_id
  }

}




  # tags = {
  #   Name = each.key == "0" ? "PrimaryEC2" : "EC2Worker${each.key}" 
  # }


#   tags = concat(
#   [
#     {
#       "Name" = "i1"
#       "propagate_at_launch" = true
#     },
#     {
#       "Name" = "i2"
#       "propagate_at_launch" = true
#     },
#     {
#       "key" = "Name"
#       "value" = "i3"
#       "propagate_at_launch" = true
#     },
#   ],
# )

    # dynamic "tag" {
    # for_each = data.aws_default_tags.current.tags
    # content {
    #   key                 = tag.key
    #   value               = tag.value
    #   propagate_at_launch = true
    # }
    # }

  # dynamic "tag" {
  #   for_each = data.aws_default_tags.example.tags
  #   content {
  #     key                 = tag.key
  #     value               = tag.value
  #     propagate_at_launch = true
  #   }
  # }

  # tags = [
  #   {
  #     key = "instance"
  #     value = "instance1"
  #     propagate_at_launch = true
  #   },
  #   {
  #     key = "instance"
  #     value = "instance2"
  #     propagate_at_launch = true
  #   }
  # ]

  #   tag = [
  #   {
  #     key                 = "Environment"
  #     value               = "dev"
  #     propagate_at_launch = true
  #   },
  #   {
  #     key                 = "Project"
  #     value               = "megasecret"
  #     propagate_at_launch = true
  #   },
  # ]


  # tags = concat(
  #   tolist(
  #     {
  #       key                 = "Name"
  #       value               = "i1"
  #       propagate_at_launch = false
  #     },
  #     {
  #       key                 = "Name"
  #       value               = "i2"
  #       propagate_at_launch = false
  #     }
  #     ),
  #   var.asg_tags
  # )
  #  }

  # tags = concat(
  #   [
  #     {
  #       "key"                 = "Name"
  #       "value"               = "instance1"
  #       "propagate_at_launch" = true
  #     },
  #     {
  #       "key"                 = "Name"
  #       "value"               = "instance2"
  #       "propagate_at_launch" = true
  #     },
  #   ],
  #   var.extra_tags,
  # )

  # tags = ["${data.null_data_source.tags.*.outputs}"]

#     dynamic "tag" {
#     for_each = var.custom_tags
#     content {
#       key                 = tag.key
#       value               = tag.value
#       propagate_at_launch = true
#     }
# }


# data "null_data_source" "tags" {
#   count = "${length(keys(var.tags))}"

#   inputs = {
#     key                 = "${element(keys(var.tags), count.index)}"
#     value               = "${element(values(var.tags), count.index)}"
#     propagate_at_launch = true
#   }
# }


resource "aws_autoscaling_policy" "target_tracking_policy" {
name = "ngnix_scale_out"
policy_type = "TargetTrackingScaling"
autoscaling_group_name = aws_autoscaling_group.ngnix_asg.name
estimated_instance_warmup = 20
target_tracking_configuration {
predefined_metric_specification {
predefined_metric_type = "ASGAverageCPUUtilization"
}
    target_value = "70"
}
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "ngnix_scale_in"
  autoscaling_group_name = aws_autoscaling_group.ngnix_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 20
}

resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_description   = "Monitors CPU utilization for ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]
  alarm_name          = "ngnix_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "EC2_scale_in"
  metric_name         = "CPUUtilization"
  threshold           = "20"
  evaluation_periods  = "2"
  period              = "60"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ngnix_asg.name
  }
}


data "aws_instances" "test" {
  instance_tags = {
    Name = "instance"
  }

    filter {
    name   = "instance.group-id"
    values = [aws_security_group.nginx_sg.id]
  }

  instance_state_names = ["running", "stopped"]

  depends_on = [aws_autoscaling_group.ngnix_asg,
  aws_lb.ngnix_lb,
  ]
}

# resource "aws_eip" "test" {
#   count    = length(data.aws_instances.test.ids)
#   instance = data.aws_instances.test.ids[count.index]

#   depends_on = [aws_autoscaling_group.ngnix_asg,
#   aws_lb.ngnix_lb,
#   ]
# }

# resource "aws_ec2_tag" "example1" {
#   count    = length(data.aws_instances.test.ids)
#   resource_id = data.aws_instances.test.ids[0]
#   key         = "Name"
#   value       = "instance1"

#   depends_on = [aws_autoscaling_group.ngnix_asg,
#   aws_lb.ngnix_lb,
#   ]
# }

# resource "aws_ec2_tag" "example2" {
#   count    = length(data.aws_instances.test.ids)
#   resource_id = data.aws_instances.test.ids[1]
#   key         = "Name"
#   value       = "instance2"

#   depends_on = [aws_autoscaling_group.ngnix_asg,
#   aws_lb.ngnix_lb,
#   ]
# }

