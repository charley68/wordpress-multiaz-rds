

resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "maxai-wordpress-efs"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    project = var.project
  }
}

resource "aws_efs_mount_target" "wordpress_efs_mt" {

  depends_on = [ aws_subnet.public1, aws_subnet.public2 ]
 
  count = length(var.availability_zone) 
  //count = var.ec2Count  // Override this here for quicker testing with one EC2
  subnet_id = local.public_subnets[count.index]

  file_system_id = aws_efs_file_system.wordpress_efs.id
  security_groups = [aws_security_group.efs_sg.id]


}