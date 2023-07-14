import os

import boto3

def lambda_handler(event, context): 
    s3_bucket_name = os.environ['S3_BUCKET']
    input_path = os.environ['INPUT_PATH']
    output_path = os.environ['OUTPUT_PATH']
    # endpoint_url = os.environ['ENDPOINT_URL']
    model_arn = os.environ['MODEL_ARN']
    model_name = os.environ['MODEL_NAME']
    data_role = os.environ['DATA_ROLE']
    kms_key_arn = os.environ['KMS_ARN']

    client = boto3.client('comprehend')

    response = client.list_document_classifiers(
        Filter={
            'DocumentClassifierName': model_name
        }
    )
    version = int(response['DocumentClassifierPropertiesList'][0]['VersionName']) + 1 

    response = client.create_document_classifier(
        DocumentClassifierName=model_name,
        VersionName= str(version),
        DataAccessRoleArn=data_role,
        InputDataConfig={
            'DataFormat': 'COMPREHEND_CSV',
            'S3Uri': f's3://{s3_bucket_name}/{input_path}/collated_output.csv'
            # 'TestS3Uri': 'string'
        },
        OutputDataConfig={
            'S3Uri': f's3://{s3_bucket_name}/{output_path}',
            'KmsKeyId': kms_key_arn
        },
        LanguageCode='en',
        VolumeKmsKeyId=kms_key_arn,
        Mode='MULTI_CLASS',
        ModelKmsKeyId=kms_key_arn
    )

    print(response)