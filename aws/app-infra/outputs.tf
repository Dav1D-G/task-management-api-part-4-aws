output "app_url" {
  value = "http://${aws_lb.app.dns_name}"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app.repository_url
}
