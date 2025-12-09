resource "aws_eip" "nlb_a" {
  domain = "vpc"
}

resource "aws_eip" "nlb_b" {
  domain = "vpc"
}

resource "aws_lb_target_group" "target_group" {
  name = "${var.resource_name_prefix}-nlb-tg"
  port = 443
  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200-399"
    path                = "/api/actuator/health"
    port                = "9085"
    protocol            = "HTTPS"
    timeout             = 6
    unhealthy_threshold = 2
  }
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  tags        = var.tags
  target_type = "alb"

}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = var.target_alb_arn
}

resource "aws_lb" "external_nlb" {
  name               = "${var.resource_name_prefix}-external-nlb"
  internal           = false
  load_balancer_type = "network"
  tags               = var.tags

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true

  subnet_mapping {
    subnet_id     = var.subnet_ids[0]
    allocation_id = aws_eip.nlb_a.id
  }

  subnet_mapping {
    subnet_id     = var.subnet_ids[1]
    allocation_id = aws_eip.nlb_b.id
  }

  access_logs {
    bucket  = var.lb_access_logs_bucket
    prefix  = "NLB/${var.current_account_id}/${var.resource_name_prefix}-external-nlb"
    enabled = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.external_nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
