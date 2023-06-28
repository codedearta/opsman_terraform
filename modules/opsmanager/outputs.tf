# output "ip" { value = "${aws_eip.opsman_ip.*.public_ip}" }
output "private_dns" { value= "${aws_instance.opsman_demo.*.private_dns}" }
output "public_dns" { value= "${aws_instance.opsman_demo.*.public_dns}" }