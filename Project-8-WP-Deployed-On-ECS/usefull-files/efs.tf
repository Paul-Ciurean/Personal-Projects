###########
#   EFS   #
###########

resource "aws_efs_file_system" "p8_efs" {
  creation_token = "efs-${var.name}"

  tags = {
    Name = "EFS-${var.name}"
  }
}

resource "aws_efs_mount_target" "efs_mount_targets" {
  for_each = {
    alpha = aws_subnet.subnets["subnet-1"].id
    beta  = aws_subnet.subnets["subnet-2"].id
  }

  file_system_id  = aws_efs_file_system.p8_efs.id
  subnet_id       = each.value
  security_groups = [aws_security_group.p8_sg.id]
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.p8_efs.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/"
    creation_info {
      owner_uid = 1000
      owner_gid = 1000
      permissions = "755"
    }
  }
}