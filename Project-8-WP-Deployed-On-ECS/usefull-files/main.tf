#################
# Load Balancer #
#################

resource "aws_lb_target_group" "p8" {
  name        = "target-group-lb-${var.name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.project_8.id
  target_type = "ip"
}

resource "aws_lb" "p8" {
  name               = "lb-${var.name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.p8_sg.id]
  subnets            = [aws_subnet.subnets["subnet-1"].id, aws_subnet.subnets["subnet-2"].id]

  tags = {
    Environment = "LB-${var.name}"
  }
}

resource "aws_lb_listener" "p8" {
  load_balancer_arn = aws_lb.p8.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.p8.arn
  }
}

output "Load_Balancer_DNS" {
  value = aws_lb.p8.dns_name
}


###############
# ECR and ECS #
###############
resource "aws_ecr_repository" "p8_ecr" {
  name                 = "wordpress-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "p8" {
  family                   = "task-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = "arn:aws:iam::<account-number>:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::<account-number>:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "container-${var.name}"
      image     = "<account-number>.dkr.ecr.<region>.amazonaws.com/wordpress-repo:wordpress"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
        "mountPoint": [
          {
            "sourceVolume": "service-storage"
            "containerPath": "/mnt/efs"
          }
        ]
      environment = [
        { name = "WORDPRESS_DB_HOST", value = "mydb.clsec22m6ttt.<region>.rds.amazonaws.com" },
        { name = "WORDPRESS_DB_USER", value = var.username },
        { name = "WORDPRESS_DB_PASSWORD", value = var.password },
        { name = "WORDPRESS_DB_NAME", value = "mydb" }
      ]
    }
  ])
  volume {
    name = "service-storage"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.p8_efs.id
      transit_encryption = "ENABLED"
      root_directory = "/"
      authorization_config {
        access_point_id = aws_efs_access_point.test.id
      }
    }
  }
}


resource "aws_ecs_cluster" "p8" {
  name = "p8-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "p8" {
  name            = "ecs-service-${var.name}"
  cluster         = aws_ecs_cluster.p8.id
  task_definition = aws_ecs_task_definition.p8.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnets["subnet-1"].id, aws_subnet.subnets["subnet-2"].id]
    security_groups  = [aws_security_group.p8_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.p8.arn
    container_name   = "container-${var.name}"
    container_port   = 80
  }
}

