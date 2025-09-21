
terraform {
  backend "s3" {
    bucket = "state-terraform-bucket-nawy-project"
    region = "eu-north-1"
    profile= "nawy"
    key = "backend_state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}

variable "DOCKERHUB_USERNAME" {}
variable "Github_sha" {}

resource "aws_ecs_cluster" "node_project_cluster" {
 name = "node_project"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "node_project_task" {
  family                   = "node_project_task"
  container_definitions    = jsonencode([
    {
      name      = "my-node-app"
      # image     = "${var.DOCKERHUB_USERNAME}/nawy_node_app:${var.Github_sha}" # Replace with your container image
      image     =  "public.ecr.aws/e7o5d6f3/nodejsnawy:${var.Github_sha}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"  

  cpu    = 256
  memory = 512


   runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}
resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Allow HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  #   {
    
  #   from_port   = 3000
  #   to_port     = 3000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  
  # },
  #   {
    
  #   from_port   = 3000
  #   to_port     = 3000
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  
  # }
  # ]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet" "default_c" {
  filter {
    name   = "availability-zone"
    values = ["eu-north-1c"]
  }
}
data "aws_subnet" "default_b" {
  filter {
    name   = "availability-zone"
    values = ["eu-north-1b"]
  }
}
data "aws_subnet" "default_a" {
  filter {
    name   = "availability-zone"
    values = ["eu-north-1a"]
  }
}
resource "aws_lb" "node_project_lb" {
  name               = "NodeProjectLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = [data.aws_subnet.default_a.id,data.aws_subnet.default_b.id,data.aws_subnet.default_c.id]

  # enable_deletion_protection = true
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.node_project_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-node-project-tg.arn
  }

}
data "aws_vpc" "default" {
  default = true
}
resource "aws_lb_target_group" "ip-node-project-tg" {
  name        = "node-project-tg"
  port        = 3000
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
  region = "eu-north-1"
}

# data "aws_vpc" "main" {
# id = "vpc-05dc28f690951d201"
# }
resource "aws_ecs_service" "node_project_service" {
  name            = "node_project_service"
  cluster         = aws_ecs_cluster.node_project_cluster.id
  task_definition = aws_ecs_task_definition.node_project_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ip-node-project-tg.arn
    container_name   = "my-node-app"
    container_port   = 3000
  }
  network_configuration {
      subnets         = [
        data.aws_subnet.default_a.id,
        data.aws_subnet.default_b.id,
        data.aws_subnet.default_c.id
      ]
      security_groups = [aws_security_group.ecs_service_sg.id]
      assign_public_ip = true
    }
}