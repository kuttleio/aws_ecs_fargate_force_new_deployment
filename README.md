# ECS Fargate - Force New Deployment
Force New Deployment for ECS Fargate services

### Solution
1. Lambda-1 lists ECS fargate services once a week and push them one-by-one to SQS
2. Lambda-2 gets 1 message from SQS every 15 minutes and triggers Force New Deployment

### Services
1. Lambda-1
2. Lambda-2
3. SQS

