resource "aws_sns_topic" "this" {
  for_each     = var.topics
  name         = each.value.name
  display_name = try(each.value.display_name, null)

  tags = merge(var.tags, try(each.value.tags, {}))
}

locals {
  flattened_subs = flatten([
    for k, v in var.topics : [
      for i, s in try(v.subscriptions, []) : {
        key       = "${k}-${i}-${s.protocol}-${s.endpoint}"
        topic_key = k
        protocol  = s.protocol
        endpoint  = s.endpoint
      }
    ]
  ])
}

resource "aws_sns_topic_subscription" "this" {
  for_each  = { for s in local.flattened_subs : s.key => s }
  topic_arn = aws_sns_topic.this[each.value.topic_key].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
