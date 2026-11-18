import os
import boto3

def lambda_handler(event, context):
    sns = boto3.client('sns')
    sns.publish(
        TopicArn=os.environ['TOPIC_ARN'],
        Message='Hello, world!',
        Subject='This is a subject'
    )
    return {'statusCode': 200, 'body': 'Sent!'}