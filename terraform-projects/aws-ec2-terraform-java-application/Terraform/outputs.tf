output "curl" {
  value = "curl -H 'Content-Type: application/json' -X POST -d '{\"name\": \"YHU\"}' https://${aws_instance.web-server-instance.public_ip}:8080/greeting?name=YHU"
}
