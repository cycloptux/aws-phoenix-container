output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "docdb_endpoint" {
  value = "${aws_docdb_cluster.main.endpoint}"
}

output "ecr_repository" {
  value = "${aws_ecr_repository.tf_phoenix.repository_url}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.app.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.app.id}"
}

output "elb_hostname" {
  value = "${aws_alb.main.dns_name}"
}
