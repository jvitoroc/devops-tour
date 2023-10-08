locals {
  prefix = "/${var.project_name}/${var.env}"
}

resource "aws_ssm_parameter" "api_url" {
  name           = "${local.prefix}/api_url"
  type           = "String"
  insecure_value = "http://api.euteamoleticia.com"

  lifecycle {
    ignore_changes = [ insecure_value ]
  }
}

data "aws_ssm_parameters_by_path" "parameters" {
  path      = local.prefix
  recursive = true
}

data "aws_ssm_parameter" "parameters" {
  for_each = toset(data.aws_ssm_parameters_by_path.parameters.names)
  name = each.key
}
