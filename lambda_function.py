import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

INSTANCE_ID = os.environ['INSTANCE_ID']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        response = ec2.describe_instances(InstanceIds=[INSTANCE_ID])
        state = response['Reservations'][0]['Instances'][0]['State']['Name']

        logger.info(f"Current EC2 instance state: {state}")

        if state == "running":
            ec2.reboot_instances(InstanceIds=[INSTANCE_ID])
            message = f"EC2 instance {INSTANCE_ID} was rebooted due to API latency alert."
        else:
            message = f"EC2 instance {INSTANCE_ID} is in '{state}' state. No action taken."

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Automated Incident Remediation",
            Message=message
        )

        logger.info(message)
        return {"status": "success", "message": message}

    except Exception as e:
        logger.error(str(e))
        raise