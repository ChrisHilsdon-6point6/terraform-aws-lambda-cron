# Terraform AWS Lambda Cron
A terraform configuration to provision Lambda function that triggers on a cron schedule via EventBridge Scheduler.

Example Python Lambda prints the current time. You can see the output in the CloudWatch log group that is created. The schedule is set to run every 5 mins.

## Resources used
 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule