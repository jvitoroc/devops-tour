variable "annotations" {
    type = map(string)
    default = null
}

variable "class_name" {
    type = string
}

variable "api_host" {
    type = string
    default = null
}

variable "app_host" {
    type = string
    default = null
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}