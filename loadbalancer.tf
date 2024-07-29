locals {
  tags = {
    Project = var.project
  }
}

resource "aws_lb_target_group" "lb-TG" {
  name = "${var.project}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.this.id
}

# Register our EC2 instance with the Target Group
resource "aws_lb_target_group_attachment" "wordpress-tg" {

  target_group_arn = aws_lb_target_group.lb-TG.arn

    for_each = {
       for k, v in aws_instance.wordpress : k => v
  }

  target_id        = each.value.id
}



# Create Load Balancer
resource "aws_lb" "app-LB" {
  name = "${var.project}-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LB-SG.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
 
  tags = local.tags
}

# We want to foward traffic from HTTP/80 to our TG
resource "aws_lb_listener" "LB-Listener" {
  load_balancer_arn = aws_lb.app-LB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-TG.arn
  }

  tags = local.tags
}