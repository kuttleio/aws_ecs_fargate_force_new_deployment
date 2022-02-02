# ----------------------------------------------------------------- #
# This Lambda: 
# 1. Gets one message from SQS with ECS Cluster Name & ECS Service
# 2. Triggers Force New deployment
# 3. Deletes the message from SQS
# ----------------------------------------------------------------- #

import boto3
import json
import os

sqs_url = os.environ["SQS_URL"]

def update_ecs_service(ecs_cluster, ecs_service):
    ecs = boto3.client('ecs')
    update_service = ecs.update_service(
        cluster=ecs_cluster,
        service=ecs_service,
        forceNewDeployment=True,
    )
    print('Service updated:', ecs_service)

def remove_message_from_sqs(message_receipt_handle):
    sqs = boto3.client('sqs')
    remove_message_from_sqs = sqs.delete_message(
        QueueUrl=sqs_url,
        ReceiptHandle=message_receipt_handle,
    )
    print('SQS message deleted', message_receipt_handle)

def lambda_handler(event, context):
    sqs = boto3.client('sqs')
    
    messages = sqs.receive_message(
        QueueUrl=sqs_url,
        MaxNumberOfMessages=1,
        )
    
    message = messages['Messages'][0]
    message_receipt_handle = message.get('ReceiptHandle')
    message = json.loads(message['Body'])
    
    ecs_cluster = message['ecs_cluster']
    ecs_service = message['ecs_fargate_service']
    
    print('\nTriggering Force New Deployment\n')
    
    update_ecs_service(ecs_cluster, ecs_service)
    remove_message_from_sqs(message_receipt_handle)
