output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = module.web.bastion_public_ip
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "ssh_command_bastion" {
  description = "SSH command for bastion"
  value       = "ssh -i ~/.ssh/cloudfinal-key ec2-user@${module.web.bastion_public_ip}"
}
