# Generate a TLS private key per EC2 instance
resource "tls_private_key" "ec2_keys" {
  for_each  = var.instances
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair per instance
resource "aws_key_pair" "ec2_keys" {
  for_each = var.instances

  key_name   = each.key
  public_key = tls_private_key.ec2_keys[each.key].public_key_openssh
}

# Launch EC2 instances
resource "aws_instance" "ec2" {
  for_each = var.instances

  ami                         = each.value.ami_id
  instance_type               = var.instance_type
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = each.value.public_ip_enabled
  vpc_security_group_ids      = each.value.security_group_ids
  iam_instance_profile        = each.value.iam_instance_profile

  key_name = aws_key_pair.ec2_keys[each.key].key_name

  user_data = try(each.value.user_data, null)

  tags = {
    Name = each.value.name
  }
}