# ----------------------------------------------------------------- #
# This Lambda: 
# 1. Gets a list of ECS services in the selected ECS cluster
# 2. Pushes them one-by-one as messages to SQS
# ----------------------------------------------------------------- #

import boto3
import json
import os

ecs_cluster     = os.environ["ECS_CLUSTER"]
sqs_url         = os.environ["SQS_URL"]

def push_to_sqs(message):
    sqs = boto3.client('sqs')
    push_to_sqs = sqs.send_message(
        QueueUrl=sqs_url,
        MessageBody=message,
    )

def lambda_handler(event, context):
    ecs = boto3.client('ecs')
    
    services = ecs.list_services(
        cluster=ecs_cluster,
        maxResults=100,
    )

    print('\n --- Fargate Services --- ')
    for service in services.get('serviceArns'):
        echo = service[43:] + "\n--> Pushed to SQS"
        msg = json.dumps({'ecs_cluster': ecs_cluster, 'ecs_fargate_service': service})
        push_to_sqs(msg)
        print(echo)
