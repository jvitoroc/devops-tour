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
    ignore_changes = [ insecure_value ]
  }
}

resource "aws_ssm_parameter" "api_image" {
  name           = "${local.prefix}/api-image"
  type           = "String"
  insecure_value = "jvitoroc17/devops-tour-api:latest"

  lifecycle {
    ignore_changes = [ insecure_value ]
  }
}

resource "aws_ssm_parameter" "app_image" {
  name           = "${local.prefix}/app-image"
  type           = "String"
  insecure_value = "jvitoroc17/devops-tour-app:latest"

  lifecycle {
    ignore_changes = [ insecure_value ]
  }
}

data "aws_ssm_parameters_by_path" "env_vars_parameters" {
  path      = local.envVarsPrefix
  recursive = true
}

data "aws_ssm_parameter" "env_vars_parameters" {
  for_each = toset(data.aws_ssm_parameters_by_path.parameters.names)
  name = each.key
}
