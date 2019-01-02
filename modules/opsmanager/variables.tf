variable "ami" { default = "ami-0274e11dced17bb5b" }
variable "instance_type" { default = "t2.xlarge" }
variable "key_name" { default = "sepp_renfer_awskey_mongodb" }
variable "private_key" {}
variable "name" { default = "opsmanager_1" }
variable "count" { default = 1 }