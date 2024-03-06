resource "aws_launch_template" "example" {
  name                   = "aws20-example-template"
  image_id               = "ami-01bdfa88de8e62e35"
  instance_type          = "t2.micro"
  key_name               = "aws20-key"
  vpc_security_group_ids = [aws_security_group.web.id, aws_security_group.ssh.id]

  user_data = base64encode(data.template_file.web_output.rendered)

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "example" {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  name               = "aws20-asg-example"
  max_size           = 2
  min_size           = 1
  desired_capacity   = 1

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "aws20-asg-example"
    propagate_at_launch = true
  }
}


resource "aws_lb" "example" {
  name = "aws20-alb-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 8080
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}


resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


resource "aws_lb_target_group" "asg" {
  name = "aws20-target-group-example"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}


resource "aws_security_group" "alb" {
  name = "aws20-sg-example-alb"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "web" {
  name = "aws20-sg-example-web"
  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ssh" {
  name = "aws20-sg-example-ssh"
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


data "template_file" "web_output" {
  template = file("${path.module}/web.sh")
  vars = {
    web_port = "${var.web_port}"
  }
}