output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_arns" {
  value = values(aws_subnet.main)[*].arn
}

output "subnet_ids" {
  value = values(aws_subnet.main)[*].id
}