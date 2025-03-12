resource "aws_instance" "data_migrate_ec2" {
  ami                    = var.amazon_linux_ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.private_app_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.app_server_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.s3_full_access_instance_profile.name

  user_data = base64encode(templatefile("${path.module}/migrate-sql.sh.tpl", {
    RDS_ENDPOINT        = aws_db_instance.database_instance.endpoint
    RDS_DB_NAME         = var.rds_db_name
    RDS_DB_USERNAME     = var.rds_db_username
    RDS_DB_PASSWORD     = var.rds_db_password
  }))

  depends_on = [aws_db_instance.database_instance]

  tags = {
    Name = "${var.project_name}-${var.environment}-data-migrate-ec2"
  }
}