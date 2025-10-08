resource "aws_lb_target_group" "target_group" {
  name     = "${var.resource_name_prefix}-internal-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags     = var.tags
  target_type = "alb"

}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.target_alb_arn
#   port             = 80
}

resource "aws_lb" "internal_alb" {
  name               = "${var.resource_name_prefix}-external-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  tags               = var.tags

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}