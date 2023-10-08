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

variable "frontend_host" {
    type = string
    default = null
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}