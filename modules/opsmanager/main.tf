resource "aws_instance" "opsman_demo" {
  count = "${var.count}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"

  security_groups = ["opsman_demo"]
  tags {
    Name = "${var.name}-${count.index}"
  }

  provisioner "file" {
    source      = "${path.module}/mongod.conf"
    destination = "/tmp/mongod.conf.orig"
  }

  provisioner "file" {
    source      = "${path.module}/keyfile"
    destination = "/tmp/keyfile"
  }

  provisioner "file" {
    source      = "${path.module}/gen.key"
    destination = "/tmp/gen.key"
  }

  provisioner "file" {
    source      = "${path.module}/mongodb-enterprise.repo"
    destination = "/tmp/mongodb-enterprise.repo"
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/provision.sh"
    ]
  }
  
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${var.private_key}"
  }
}

resource "aws_eip" "opsman_ip" {
  count = "${var.count}"
  instance = "${element(aws_instance.opsman_demo.*.id, count.index)}"
}