locals {
  prefix = "/${var.project_name}/${var.env}"
}

locals {
  envVarsPrefix = "${local.prefix}/env-vars"
}

resource "aws_ssm_parameter" "api_url" {
  name           = "${local.envVarsPrefix}/api-url"
  type           = "String"
  insecure_value = "http://api.euteamoleticia.com"

  lifecycle {
    ignore_changes = [insecure_value]
  }
}

resource "aws_ssm_parameter" "api_repository" {
  name  = "${local.prefix}/api-image"
  type  = "String"
  value = "jvitoroc17/devops-tour-api"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "app_repository" {
  name  = "${local.prefix}/app-image"
  type  = "String"
  value = "jvitoroc17/devops-tour-app"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameters_by_path" "env_vars_parameters" {
  path      = local.envVarsPrefix
  recursive = true
}

data "aws_ssm_parameter" "env_vars_parameters" {
  for_each = toset(data.aws_ssm_parameters_by_path.parameters.names)
  name     = each.key
}
