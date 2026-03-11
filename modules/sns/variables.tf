variable "topics" {
  type = map(object({
    name  = string
    email = string
  }))
  description = "Map of SNS topics to create with email subscriptions"
}
