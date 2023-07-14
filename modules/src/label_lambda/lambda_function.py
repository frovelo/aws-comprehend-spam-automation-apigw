import sys
import os
import csv
import codecs

import boto3

def lambda_handler(event, context):
    col_names = ['type', 'body']
    s3_bucket = os.environ['S3_BUCKET']
    s3_bucket_input_path = os.environ['INPUT_PATH']
    s3_bucket_spam_path = os.environ['SPAM_PATH']
    s3_bucket_ham_path  = os.environ['HAM_PATH']
    # s3_delete_objects   = os.environ['DELETE_OBJECTS']

    client = boto3.client('s3')

    os.chdir('/tmp') # Lambda filesystem, 512mb
    try:
        client.download_file(s3_bucket, f'{s3_bucket_input_path}/collated_output.csv', './collated_output.csv')
    except Exception:
        pass

    with open('./collated_output.csv', 'w', encoding='UTF8', newline='') as csv_file:
        writer = csv.writer(csv_file)

        # get spam files
        spam_response = client.list_objects_v2(
            Bucket=s3_bucket,
            MaxKeys=1000,
            Prefix=f'{s3_bucket_spam_path}/' 
        )
        spam_files = spam_response['Contents']

        # while spam_response['IsTruncated']:
        #     spam_response = client.list_objects_v2(
        #         Bucket=s3_bucket,
        #         MaxKeys=1000,
        #         Prefix=f'{s3_bucket_spam_path}/',
        #         ContinuationToken= spam_response['NextContinuationToken']
        #     )

        #     spam_files = spam_files + spam_response['Contents']

        # get ham files
        ham_response = client.list_objects_v2(
            Bucket=s3_bucket,
            MaxKeys=1000,
            Prefix=f'{s3_bucket_ham_path}/' 
        )
        ham_files = ham_response['Contents']

        # while ham_response['IsTruncated']:
        #     ham_response = client.list_objects_v2(
        #         Bucket=s3_bucket,
        #         MaxKeys=1000,
        #         Prefix=f'{s3_bucket_ham_path}/',
        #         ContinuationToken= ham_response['NextContinuationToken']
        #     )

        #     ham_files = ham_files + ham_response['Contents']

        print('Labeling spam files.')
        for spam_object in spam_files:
            # Check whether file is in text format or not
            object_key = spam_object['Key']
            if object_key.endswith(".txt"):
                client.download_file(s3_bucket, object_key, './temp_file.txt')

                # call read text file function
                path = './temp_file.txt'
                with codecs.open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    if f.readable():
                        # write contents to csv
                        val = f.read()
                        writer.writerow(["spam", val])
                    else:
                        print (f'ERROR: could not read: ./{object_key}.')

                os.remove(f'./temp_file.txt')
                response = client.delete_object(
                    Bucket=s3_bucket,
                    Key=object_key
                )

        print('Labeling ham files.')
        for ham_object in ham_files:
            # Check whether file is in text format or not
            object_key = ham_object['Key']
            if object_key.endswith(".txt"):
                client.download_file(s3_bucket, object_key, './temp_file.txt')

                # call read text file function
                path = './temp_file.txt'
                with codecs.open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    if f.readable():
                        # write contents to csv
                        val = f.read()
                        writer.writerow(["ham", val])
                    else:
                        print (f'ERROR: could not read: ./{object_key}.')

                os.remove('./temp_file.txt')
                response = client.delete_object(
                    Bucket=s3_bucket,
                    Key=object_key
                )

        # delete previous version of training data
        try:
            response = client.delete_object(
                Bucket=s3_bucket,
                Key=f'{s3_bucket_input_path}/collated_output.csv'
            )
        except Exception:
            pass

        # Upload the file
        response = client.upload_file('./collated_output.csv', s3_bucket, f'{s3_bucket_input_path}/collated_output.csv')

