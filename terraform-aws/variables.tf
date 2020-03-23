provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}

variable "general_name" {
  default = "locust-fargate"
}

variable "slave_count" {
  default = 10
}

variable "fargate_cpu" {
  default = 256
}

variable "fargate_memory" {
  default = 512
}

variable "locust_container" {
  default = "xxxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/locust_scripts:latest"
}

variable "locust_script_path" {
  default = "/scripts/locustfile.py"
}
