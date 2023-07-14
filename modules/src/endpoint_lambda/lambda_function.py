import os
import json

import boto3

def lambda_handler(event, context): 
    print(event)

    request_payload = json.loads(event['body'])['requestPayload']
    endpoint_url = os.environ['ENDPOINT_URL']

    print(request_payload)


    client = boto3.client('comprehend')

    response_payload = []
    for email in request_payload:
        email_text = email['text']
        email_id = email['id']
        response = client.classify_document(
            Text=email_text,
            EndpointArn=endpoint_url
        )

        response_payload.append({email_id:response})

    print(response_payload)
    if len(response_payload) == len(request_payload):
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': f'{response_payload}'
        }
    else:
        return {
            'statusCode': 500,
            'body': 'Issue with reaching Comprehend Endpoint with your requestPayload. Did not return same len(val)'
        }
