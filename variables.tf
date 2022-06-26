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
variable cloudwatch_logs_retention_in_days {
    type    = number
    default = 3
}

variable schedule {
    description = "Schedule rule for Lambda"
    default     = {
        name            = "run-every-week"
        description     = "Fires Lambda every Sunday morning at 7 UTC"
        expression      = "cron(0 7 ? * SUN *)"
    }   
}
