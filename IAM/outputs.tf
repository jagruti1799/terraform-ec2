output "aws_iam_instance_profile_arn" {
    value = aws_iam_instance_profile.nginx_profile.arn
}

output "aws_iam_role" {
    value = aws_iam_role.ngnix_role.id
}