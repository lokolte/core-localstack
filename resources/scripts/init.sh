#!/usr/bin/env bash

IFS=','
read -ra ADDR <<< "$LSTACK_SERVICES"
for service_th in "${ADDR[@]}"; do
    if [ $service_th == 's3' ]
    then
        awslocal cloudformation create-stack --template-body file://${DATADIR}/templates/s3template.yml --stack-name teststack

        #To create a bucket
        echo -e "Creating bucket $LSTACK_BUCKET for server $LSTACK_HOST in port $LSTACK_PORT"
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 mb s3://${LSTACK_BUCKET}

        #To copy files into s3 localstack
        echo -e "Copying s3_test_data content to $DATADIR/data"
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 cp ${DATADIR}/resources/local_data/s3_test_data.json s3://${LSTACK_BUCKET}

        #To list the files in s3
        echo -e "Lising content of $LSTACK_BUCKET"
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET}
    fi
done