resource "aws_security_group" "lambda" {
  name        = "LambdaSG"
  description = "Shared Security Group for accessing Aurora"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "aurora" {
  name        = "RDSAuroraSG"
  description = "Allow access to RDS Aurora Postgres"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL/Aurora"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
