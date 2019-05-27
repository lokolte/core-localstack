#!/bin/sh

#echo $DATADIR

echo "127.0.0.1     localstack-server" >> /etc/hosts

echo $LOCALSTACK_SERVICES

cat /etc/hosts

#aws configure
#fill key and Secret with foo, location us-east-1, last enter return key to avoid fill last one

#To create a bucket
echo -e "Creating bucket $LSTACK_BUCKET for server $LSTACK_HOST in port $LSTACK_PORT"
aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET}

#To copy files into s3 localstack
echo -e "Copying test_data content to $DATADIR/data"
aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 cp ${DATADIR}/data/test_data.part s3://${LSTACK_BUCKET}

#To list the files in s3
echo -e "Lising content of $LSTACK_BUCKET"
aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET}