# ======================
# APP EC2 OUTPUTS
# ======================
output "app_ec2_ips" {
  value = module.app_ec2.all_ips
}

output "app_ec2_private_keys" {
  value     = module.app_ec2.ec2_private_keys
  sensitive = true
}

# APP EC2 – PER INSTANCE (EASY CLI)
output "dev_app_private_key" {
  value     = module.app_ec2.ec2_private_keys["dev-app-ec2"]
  sensitive = true
}

output "stage_app_private_key" {
  value     = module.app_ec2.ec2_private_keys["stage-app-ec2"]
  sensitive = true
}

output "prod_app_private_key" {
  value     = module.app_ec2.ec2_private_keys["prod-app-ec2"]
  sensitive = true
}

# ======================
# NGINX EC2 OUTPUTS (MAP)
# ======================
output "nginx_ec2_ips" {
  value = module.nginx_ec2.all_ips
}

output "nginx_ec2_private_keys" {
  value     = module.nginx_ec2.ec2_private_keys
  sensitive = true
}

# NGINX EC2 – PER INSTANCE (EASY CLI)
output "dev_nginx_private_key" {
  value     = module.nginx_ec2.ec2_private_keys["dev-nginx-ec2"]
  sensitive = true
}

output "stage_nginx_private_key" {
  value     = module.nginx_ec2.ec2_private_keys["stage-nginx-ec2"]
  sensitive = true
}

output "prod_nginx_private_key" {
  value     = module.nginx_ec2.ec2_private_keys["prod-nginx-ec2"]
  sensitive = true
}

output "dev_nginx_public_ip" {
  value = module.nginx_ec2.all_ips["dev-nginx-ec2"].public_ip
}

output "stage_nginx_public_ip" {
  value = module.nginx_ec2.all_ips["stage-nginx-ec2"].public_ip
}

output "prod_nginx_public_ip" {
  value = module.nginx_ec2.all_ips["prod-nginx-ec2"].public_ip
}

# ======================
# JENKINS EC2 OUTPUTS
# ======================
output "jenkins_ec2_ips" {
  value = module.jenkins_ec2.all_ips
}

output "jenkins_ec2_private_keys" {
  value     = module.jenkins_ec2.ec2_private_keys
  sensitive = true
}

# JENKINS – PER INSTANCE
output "jenkins_private_key" {
  value     = module.jenkins_ec2.ec2_private_keys["jenkins-ec2"]
  sensitive = true
}

# ======================
# PROD DB EC2 OUTPUTS
# ======================
output "prod_db_ec2_ips" {
  value = module.prod_db_ec2.all_ips
}

output "prod_db_ec2_private_keys" {
  value     = module.prod_db_ec2.ec2_private_keys
  sensitive = true
}

# PROD DB – PER INSTANCE
output "prod_db_private_key" {
  value     = module.prod_db_ec2.ec2_private_keys["prod-db-ec2"]
  sensitive = true
}


# -----------------------------
# Outputs
# -----------------------------
output "sns_topic_arns" {
  value = module.sns.topic_arns
}
