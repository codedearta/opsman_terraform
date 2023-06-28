provider "aws" {
  region = "eu-west-1" 
}

module "securitygroup" {
  source = "./modules/securitygroup"
}

module "opsmanager" {
  source = "./modules/opsmanager"
  ami = "ami-0ca7795427fb03aa0"
  instance_type = "t2.xlarge"
  key_name = "${var.key_name}"
  private_key = "${file("~/.ssh/srenfer_mdb_aws_key.pem")}"
  name = "opsmanager ${count.index}"
  count = "${var.repl_count}"
}

resource "null_resource" "opsmanager" {
  count = "${var.repl_count}"

  provisioner "local-exec" {
    command = "echo '#!/bin/bash' > export_private_dns_names.sh"
  }

  provisioner "local-exec" {
    command = "echo export 'opsman${count.index}=${module.opsmanager.*.private_dns[count.index][0]}' >> export_private_dns_names.sh"
  }

  provisioner "file" {
    source      = "export_private_dns_names.sh"
    destination = "/tmp/export_private_dns_names.sh"
  }

  provisioner "file" {
    source      = "provision_all.sh"
    destination = "/tmp/provision_all.sh"
  }

  provisioner "file" {
    source      = "initReplSet.js"
    destination = "/tmp/initReplSet.js"
  }

  provisioner "file" {
    source      = "startMMS.sh"
    destination = "/tmp/startMMS.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/provision_all.sh", 
      "/tmp/provision_all.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/startMMS.sh", 
      "/tmp/startMMS.sh"
    ]
  }

  connection {
    host = "${tostring(module.opsmanager.*.public_dns[count.index][0])}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.ssh/srenfer_mdb_aws_key.pem")}"
  }
}
