# 로드밸런서 생성
resource "aws_lb" "example" {
  name               = "aws20-alb"
  load_balancer_type = "application"
  subnets = [data.terraform_remote_state.vpc.outputs.public-subnet-2a-id,
  data.terraform_remote_state.vpc.outputs.public-subnet-2c-id]
  security_groups = [data.terraform_remote_state.security_group.outputs.http]
}


# 로드밸런서 리스너 - Jenkins                           리스너 : 프로토콜+포트   //  리스너 룰 : 조건+작업
resource "aws_lb_listener" "jenkins_http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


# 로드밸런서 리스너 룰 - Jenkins
resource "aws_lb_listener_rule" "jenkins" {
  listener_arn = aws_lb_listener.jenkins_http.arn
  priority     = 100
  condition {
    host_header {
      values = ["aws20-jenkins.busanit-lab.com"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}


# Jenkins 대상 그룹                                            대상 유형을 인스턴스로만 지정 -> attachment 추가해서 인스턴스 등록해줘야함
resource "aws_lb_target_group" "jenkins" {
  name        = "aws20-jenkins"
  target_type = "instance"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


# target group이 EC2 단독일 경우 attachment 추가,                  attachment : 대상 그룹에 인스턴스 및 컨테이너를 등록하는 기능
resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = data.terraform_remote_state.jenkins_instance.outputs.jenkins_id
  port             = var.http_port
}


# 시작 템플릿 (이미지 id 교체 : aws20-target-image)
resource "aws_launch_template" "example" {
  name                   = "aws20-template"
  image_id               = "ami-00f8e19e904d3bfed"
  instance_type          = "t2.micro"
  key_name               = "aws20-key"
  vpc_security_group_ids = [data.terraform_remote_state.security_group.outputs.http]

  # user_data = base64encode(data.template_file.web_output.rendered)

  iam_instance_profile {
    name = "aws20-codedeploy-ec2-role"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 오토스케일링 그룹 (target 인스턴스)
resource "aws_autoscaling_group" "example" {
  vpc_zone_identifier = [data.terraform_remote_state.vpc.outputs.private-subnet-2a-id,
                         data.terraform_remote_state.vpc.outputs.private-subnet-2c-id]
  name                = "aws20-asg"
  desired_capacity    = 3
  min_size            = 1
  max_size            = 3

  target_group_arns = [aws_lb_target_group.aws20-tg.arn]
  # health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "aws20-spring-petclinic"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_target" {
  autoscaling_group_name = aws_autoscaling_group.example.id
  lb_target_group_arn = aws_lb_target_group.aws20-tg.arn
}


# 로드밸런서 리스너 - asg
resource "aws_lb_listener" "target_http" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


# 로드밸런서 리스너 룰 - asg
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.target_http.arn
  priority     = 99
  condition {
    host_header {
      values = ["aws20-target.busanit-lab.com"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws20-tg.arn
  }
}


# Target 인스턴스 대상 그룹
resource "aws_lb_target_group" "aws20-tg" {
  name     = "aws20-target-group"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

