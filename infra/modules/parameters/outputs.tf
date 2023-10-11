output "env_vars_params" {
  value = data.aws_ssm_parameter.env_vars_parameters
}

output "app_image" {
  value = resource.aws_ssm_parameter.app_image.insecure_value
}

output "api_image" {
  value = resource.aws_ssm_parameter.api_image.insecure_value
}