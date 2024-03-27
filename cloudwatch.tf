# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "example" {
  name              = "/var/log/example"
  retention_in_days = 7
}

# CloudWatch Log Stream (Optional, if needed for specific routing)
resource "aws_cloudwatch_log_stream" "example" {
  name           = "example"
  log_group_name = aws_cloudwatch_log_group.example.name
}
