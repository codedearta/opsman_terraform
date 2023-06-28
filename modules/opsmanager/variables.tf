variable "ami" { default = "ami-0094635555ed28881" }
variable "instance_type" { default = "t2.xlarge" }
variable "key_name" { default = "srenfer_mdb_aws_key" }
variable "private_key" {}
variable "name" { default = "opsmanager_1" }
variable "repl_count" { default = 1 }
