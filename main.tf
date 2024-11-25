provider "aws" {
  region = "eu-west-1"
}

# Security Group lié au VPC par défaut
resource "aws_security_group" "default" {
  vpc_id = "vpc-0035b5ae8bbbefd3f"  # ID du VPC par défaut
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Target Group pour le Load Balancer
resource "aws_lb_target_group" "target_group" {
  name        = "${var.trigram}-targetgroup"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0035b5ae8bbbefd3f"  # ID du VPC par défaut
  target_type = "instance"
}

# Application Load Balancer avec deux sous-réseaux
resource "aws_lb" "app_lb" {
  name               = "${var.trigram}-applb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.default.id]
  subnets            = ["subnet-02ae3d0545ef9967e", "subnet-01bac5268bd103c55"]  
}

# Listener pour le Load Balancer
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Launch Template pour les instances EC2
resource "aws_launch_template" "app_launch_template" {
  name          = "${var.trigram}-launch-template"
  image_id      = "ami-06399e63ed77119e2"  # Utilisez l'AMI de votre TP1
  instance_type = "t2.micro"

  # Script pour ajouter l'ID de l'instance dans la page index.html
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "<h1>Instance ID: $(curl http://169.254.169.254/latest/meta-data/instance-id)</h1>" > /var/www/html/index.html
              EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  vpc_zone_identifier  = ["subnet-02ae3d0545ef9967e", "subnet-01bac5268bd103c55"]  # Utilise les deux sous-réseaux pour haute disponibilité

  # Référence au Launch Template
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  # Associe le Target Group au Auto Scaling Group
  target_group_arns = [aws_lb_target_group.target_group.arn]

  # Tag pour les instances créées par l'Auto Scaling Group
  tag {
    key                 = "Name"
    value               = "${var.trigram}-instance"
    propagate_at_launch = true
  }
}
