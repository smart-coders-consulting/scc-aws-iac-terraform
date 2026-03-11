# # Output IPs
output "all_ips" {
  value = {
    for k, v in aws_instance.ec2 :
    k => {
      private_ip = v.private_ip
      public_ip  = v.public_ip
    }
  }
}

# Output private keys (for SSH)
output "ec2_private_keys" {
  value     = { for k, v in tls_private_key.ec2_keys : k => v.private_key_pem }
  sensitive = true
}
