resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2key" {
  key_name = "${var.project_name}-${var.environment_name}-key"
  public_key = "${tls_private_key.mykey.public_key_openssh}"
}
resource "aws_instance" "public_instance" {
  ami           = "ami-0d5eff06f840b45e9"
  instance_type = "t2.micro"
  iam_instance_profile   = "${var.iamm_profile}"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.web_sg_id}"]
  key_name = aws_key_pair.ec2key.key_name

  tags = {
        Name = "${var.project_name}-${var.environment_name}-instance"
    }
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo systemctl start httpd"
    ]
  }
        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = "${tls_private_key.mykey.private_key_pem}"
            host = self.public_ip
        }

}
