#!/usr/bin/env bash

echo -e "Configuring Host $LSTACK_HOST" >> /tmp/localstack_infra.log
echo -e "127.0.0.1     $LSTACK_HOST" >> /etc/hosts

IFS=','
read -ra ADDR <<< "$LSTACK_SERVICES"
for service_th in "${ADDR[@]}"; do
    if [ $service_th == 's3' ]
    then
        #To create a bucket
        echo -e "Creating bucket $LSTACK_BUCKET for server $LSTACK_HOST in port $LSTACK_PORT" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 mb s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log

        #Grant full access permission for public access
        echo -e "Adding full access permission to s3_test_data_development.json file." >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-bucket-acl --bucket ${LSTACK_BUCKET} --acl public-read >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-object-acl --bucket ${LSTACK_BUCKET} --key s3_test_data_development.json --grant-full-control uri=http://acs.amazonaws.com/groups/global/AllUsers >> /tmp/localstack_infra.log

        #To copy files into s3 localstack
        echo -e "Copying s3_test_data_development content to $DATADIR/data" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 cp ${DATADIR}/local_data/s3_test_data_development.json s3://${LSTACK_BUCKET}/ >> /tmp/localstack_infra.log

        #To list the files in s3
        echo -e "Lising content of $LSTACK_BUCKET" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log
    elif [ $service_th == 'kinesis' ]
    then
        # Select http or https
        HTTP_PROTOCOL="http"
        SSL_FLAG=""
        if [ $USE_SSL ]
        then
            HTTP_PROTOCOL="https"
            SSL_FLAG="--no-verify-ssl"
        fi
        # To create kinesis streams
        if [ $NUMBER_STREAM > 0 ]
        then
            for (( stream_th=1; stream_th<=$NUMBER_STREAM; stream_th++ ))
            do
                echo -e "Creating on ${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} stream ${ENVIRONMENT_NAME}.${STREAM_NAME_FIRST}.${stream_th}.${STREAM_NAME_SECOND}" >> /tmp/localstack_infra.log
                aws kinesis ${SSL_FLAG} create-stream --endpoint-url=${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} --stream-name "${ENVIRONMENT_NAME}.${STREAM_NAME_FIRST}.${stream_th}.${STREAM_NAME_SECOND}" --shard-count 1  >> /tmp/localstack_infra.log
            done
        elif [ $NUMBER_STREAM == '' ]
        then
            echo -e "Creating on ${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} stream ${STREAM_NAME}" >> /tmp/localstack_infra.log
            aws kinesis ${SSL_FLAG} create-stream --endpoint-url=${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} --stream-name ${STREAM_NAME} --shard-count 1 >> /tmp/localstack_infra.log
        fi
    elif [ $service_th == 'dinamodb' ]
    then
        # Select http or https
        HTTP_PROTOCOL="http"
        SSL_FLAG=""
        if [ $USE_SSL ]
        then
            HTTP_PROTOCOL="https"
            SSL_FLAG="--no-verify-ssl"
        fi
        # To create kinesis streams
        if [ $NUMBER_STREAM > 0 ]
        then
            for (( stream_th=1; stream_th<=$NUMBER_STREAM; stream_th++ ))
            do
                echo -e "Creating on ${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} stream ${ENVIRONMENT_NAME}.${STREAM_NAME_FIRST}.${stream_th}.${STREAM_NAME_SECOND}" >> /tmp/localstack_infra.log
                aws kinesis ${SSL_FLAG} create-stream --endpoint-url=${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} --stream-name "${ENVIRONMENT_NAME}.${STREAM_NAME_FIRST}.${stream_th}.${STREAM_NAME_SECOND}" --shard-count 1  >> /tmp/localstack_infra.log
            done
        elif [ $NUMBER_STREAM == '' ]
        then
            echo -e "Creating on ${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} stream ${STREAM_NAME}" >> /tmp/localstack_infra.log
            aws kinesis ${SSL_FLAG} create-stream --endpoint-url=${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} --stream-name ${STREAM_NAME} --shard-count 1 >> /tmp/localstack_infra.log
        fi
    fi


done

