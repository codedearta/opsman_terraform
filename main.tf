provider "aws" {
  region = "eu-west-2" 
}

module "securitygroup" {
  source = "./modules/securitygroup"
}

module "opsmanager" {
  source = "./modules/opsmanager"
  ami = "ami-0094635555ed28881"
  instance_type = "t2.xlarge"
  key_name = "${var.key_name}"
  private_key = "${file("~/.aws/sepp_renfer_awskey_mongodb.pem")}"
  name = "opsmanager"
  count = "${var.count}"
}

resource "null_resource" "opsmanager" {
  count = "${var.count}"

  provisioner "local-exec" {
    command = "echo '#!/bin/bash' > export_private_dns_names.sh"
  }

  provisioner "local-exec" {
    command = "echo export 'opsman${count.index}=${element(module.opsmanager.private_dns, count.index)}' >> export_private_dns_names.sh"
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
    host = "${element(module.opsmanager.ip, count.index)}"
    type = "ssh"
    user = "ec2-user"
    private_key = "${file("~/.aws/sepp_renfer_awskey_mongodb.pem")}"
  }
}
