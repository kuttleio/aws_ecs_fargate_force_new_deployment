variable account {}
variable name_prefix {
    type = string
}
variable standard_tags {
    type = map(string)
}
variable ecs_cluster {
    type = string
}

variable list_rule {
    description = "Schedule rule for listing service"
    default     = {
        name            = "run-every-week"
        description     = "Fires Lambda every Sunday morning"
        expression      = "cron(0 7 ? * SUN *)"
    }   
}

variable action_rule {
    description = "Schedule actions for the listed services"
    default     = {
        name            = "run-every-10-min"
        description     = "Fires Lambda every 10 minutes but only Sundays"
        expression      = "cron(0/10 * ? * SUN *)"
    }   
}
