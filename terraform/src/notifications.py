import logging
import boto3
from botocore.exceptions import ClientError

def publish_message(topic_arn, message, subject):
    sns_client = boto3.client('sns', region_name='us-east-1')
    try:
        response = sns_client.publish(
            TopicArn=topic_arn,
            Message=message,
            Subject=subject,
        )['MessageId']
    except ClientError:
        logging.info("Could not publish the message to the topic.")
        raise
    else:
        return response
