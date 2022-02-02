variable "account" {}
variable "name_prefix" {
    type = string
}
variable "standard_tags" {
    type = map(string)
}
variable "ecs_cluster" {
    type = string
}
