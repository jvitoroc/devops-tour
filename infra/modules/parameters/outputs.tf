output "env_vars_params" {
  value = data.aws_ssm_parameter.env_vars_parameters
}

output "app_repository" {
  value = resource.aws_ssm_parameter.app_repository.value
}

output "api_repository" {
  value = resource.aws_ssm_parameter.api_repository.value
}