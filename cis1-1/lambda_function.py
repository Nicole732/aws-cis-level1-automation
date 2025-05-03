import boto3
import os

def lambda_handler(event, context):
    sns = boto3.client('sns')
    org = boto3.client('organizations')
    topic_arn = os.environ.get('SNS_TOPIC_ARN')

    try:
        response = org.describe_organization()
        details = response.get('Organization', {})

        missing_fields = []
        contact = details.get('MasterAccountEmail')
        if not contact:
            missing_fields.append("MasterAccountEmail")

        if missing_fields:
            message = f"[CIS 1.1] Missing contact details: {', '.join(missing_fields)}"
        else:
            message = "[CIS 1.1] All required contact details are present."

        sns.publish(
            TopicArn=topic_arn,
            Subject="CIS 1.1 Contact Detail Check",
            Message=message
        )

    except Exception as e:
        sns.publish(
            TopicArn=topic_arn,
            Subject="CIS 1.1 Contact Detail Check Failed",
            Message=f"Error: {str(e)}"
        )