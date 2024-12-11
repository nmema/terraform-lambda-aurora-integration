resource "aws_security_group" "aurora" {
  name        = "RDSAuroraSG"
  description = "Allow access to RDS Aurora Postgres"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "PostgreSQL/Aurora"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # TODO: add Lambda Security Group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
