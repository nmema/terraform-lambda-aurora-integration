resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name = "AuroraSubnetGroup"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "integration-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = "15.4"
  database_name          = "integration"
  master_username        = var.master_username
  master_password        = var.master_password
  vpc_security_group_ids = [aws_security_group.aurora.id]
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  storage_encrypted      = true
  skip_final_snapshot    = true

  tags = {
    Name = "AuroraDBCluster"
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  identifier         = "integration-instance"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version


  tags = {
    Name = "AuroraDBInstance"
  }
}
