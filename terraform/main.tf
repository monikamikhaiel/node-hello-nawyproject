
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
 name = "node_project_cluster"

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
      image     = "${var.DOCKERHUB_USERNAME}/nawy_node_app:${var.Github_sha}" # Replace with your container image
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
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"  #?
}

# resource "aws_ecs_service" "my_service" {
#   name            = "my-app-service"
#   cluster         = aws_ecs_cluster.node_project_cluster.id
#   task_definition = aws_ecs_task_definition.node_project_task.arn
#   desired_count   = 1
#   launch_type     = "EC2"

#   network_configuration {
#     subnets          = [aws_subnet.private_subnet_1.id] # Replace with your subnet IDs
#     security_groups  = [aws_security_group.my_sg.id]     # Replace with your security group ID
#     assign_public_ip = false
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.ecs_task_execution_role_policy
#   ]
# }
# resource "aws_ecs_service" "mongo" {
#   name            = "mongodb"
#   cluster         = aws_ecs_cluster.foo.id
#   task_definition = aws_ecs_task_definition.mongo.arn
#   desired_count   = 3
#   iam_role        = aws_iam_role.foo.arn
#   depends_on      = [aws_iam_role_policy.foo]

#   ordered_placement_strategy {
#     type  = "binpack"
#     field = "cpu"
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.foo.arn
#     container_name   = "mongo"
#     container_port   = 8080
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }