#!/usr/bin/env bash

echo -e "Configuring Host $LSTACK_HOST and port $LSTACK_PORT" >> /tmp/localstack_infra.log
echo -e "127.0.0.1     $LSTACK_HOST" >> /etc/hosts

IFS=','
read -ra ADDR <<< "$LSTACK_SERVICES"
for service_th in "${ADDR[@]}"; do
    if [ $service_th == 's3' ]
    then
        awslocal cloudformation create-stack --template-body file://${DATADIR}/templates/s3template.yml --stack-name teststack >> /tmp/localstack_infra.log

        #To create a bucket
        echo -e "Creating bucket $LSTACK_BUCKET for server $LSTACK_HOST in port $LSTACK_PORT" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 mb s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log

        #Grant full access permission for public access
        echo -e "Adding full access permission to s3_test_data.json file." >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-bucket-acl --bucket ${LSTACK_BUCKET} --acl public-read >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-object-acl --bucket ${LSTACK_BUCKET} --key s3_test_data.json --grant-full-control uri=http://acs.amazonaws.com/groups/global/AllUsers >> /tmp/localstack_infra.log

        #To copy files into s3 localstack
        echo -e "Copying s3_test_data content to $DATADIR/data" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 cp ${DATADIR}/local_data/s3_test_data.json s3://${LSTACK_BUCKET}/ >> /tmp/localstack_infra.log

        #To list the files in s3
        echo -e "Lising content of $LSTACK_BUCKET" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log
    fi
done