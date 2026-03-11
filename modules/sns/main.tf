# -----------------------------
# Create SNS Topics
# -----------------------------
resource "aws_sns_topic" "this" {
  for_each = var.topics
  name     = each.value.name
}

# -----------------------------
# Subscribe Emails
# -----------------------------
resource "aws_sns_topic_subscription" "email_sub" {
  for_each  = var.topics
  topic_arn = aws_sns_topic.this[each.key].arn
  protocol  = "email"
  endpoint  = each.value.email
}

# -----------------------------
# Store SNS ARNs in Secrets Manager
# -----------------------------
resource "aws_secretsmanager_secret" "sns_secret" {
  for_each = var.topics
  name     = "${each.key}-sns-arn"
}

resource "aws_secretsmanager_secret_version" "sns_secret_version" {
  for_each      = var.topics
  secret_id     = aws_secretsmanager_secret.sns_secret[each.key].id
  secret_string = aws_sns_topic.this[each.key].arn
}
