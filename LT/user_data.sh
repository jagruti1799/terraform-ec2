#!/bin/bash
#echo Ec2instance=${var.instance[count.index]} >> /etc/ec2/ec2.config
echo "Changing Hostname"
hostname "instance1"
echo "instance1" > /etc/hostname