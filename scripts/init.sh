#!/usr/bin/env bash

echo $SERVICESs

aws configure
#fill key and Secret with foo, location us-east-1, last enter return key to avoid fill last one

#To create a bucket
aws --endpoint-url=http://${S3_HOST}:${S3_PORT} s3 ls s3://${SRC_BUCKET}

#To copy files into s3 localstack
aws --endpoint-url=http://${S3_HOST}:${S3_PORT} s3 cp /local_data/test_data.part s3://${SRC_BUCKET}

#To list the files in s3
aws --endpoint-url=http://${S3_HOST}:${S3_PORT} s3 ls s3://${SRC_BUCKET}