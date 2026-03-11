output "topic_arns" {
  description = "SNS topic ARNs"
  value       = { for k, v in aws_sns_topic.this : k => v.arn }
}
