variable db_name {}
variable db_username {}
variable db_password {}

resource "aws_rds_cluster" "aurora_cluster" {
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.04.1"
  #  db_subnet_group_name            = aws_db_subnet_group.example.name // optional
  database_name                   = var.db_name
  master_username                 = var.db_username
  master_password                 = var.db_password
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.custom_rds_profile.name
  vpc_security_group_ids          = [aws_security_group.aurora_sg.id]
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count               = 1
  identifier          = "aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.small"
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  publicly_accessible = true
}


resource "aws_rds_cluster_parameter_group" "custom_rds_profile" {
  name        = "custom-parameter-group"
  family      = "aurora-mysql8.0"
  description = "Custom parameter group for Aurora MySQL 8.0"

  parameter {
    name         = "character_set_server"
    value        = "utf8"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "thread_stack"
    value        = "4194304"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_sp_recursion_depth"
    value        = "255"
    apply_method = "pending-reboot"
  }
}
