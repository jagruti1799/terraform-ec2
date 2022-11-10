output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnetA_id" {
  value = aws_subnet.public_subnetA.id
}

output "subnetB_id" {
  value = aws_subnet.public_subnetB.id
}