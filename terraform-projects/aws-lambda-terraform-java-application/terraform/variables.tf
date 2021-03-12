variable "account_id" {
  default = "221399280476"
}

variable "region" {
  default = "us-east-1"
}

variable "lambda_payload_filename" {
  default = "../helloworldjava/target/helloworldjava-0.1.0-SNAPSHOT.jar"
}

variable "lambda_function_handler" {
  default = "us.yhu.exp.helloworld.HelloLambdaHandler"
}

variable "lambda_runtime" {
  default = "java8"
}

variable "api_path" {
  default = "helloworld"
}

variable "hello_world_http_method" {
  default = "POST"
}

variable "api_env_stage_name" {
  default = "beta"
}
