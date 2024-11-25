output "load_balancer_dns" {
  description = "DNS de l'Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.target_group.arn
}

output "autoscaling_group_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}
