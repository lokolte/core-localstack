#!/usr/bin/env bash

echo -e "Configuring Host $LSTACK_HOST" >> /tmp/localstack_infra.log
echo -e "127.0.0.1     $LSTACK_HOST" >> /etc/hosts

IFS=','
read -ra SERVICES_SPLITED <<< "$LSTACK_SERVICES"

for service_th in "${SERVICES_SPLITED[@]}"; do
    if [ $service_th == 's3' ]
    then
        awslocal cloudformation create-stack --template-body file://${DATADIR}/templates/s3template.yml --stack-name teststack >> /tmp/localstack_infra.log
        #To create a bucket
        echo -e "Creating bucket $LSTACK_BUCKET for server $LSTACK_HOST in port $LSTACK_PORT" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 mb s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log

        #Grant full access permission for public access
        echo -e "Adding full access permission to s3_test_data_development.json file." >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-bucket-acl --bucket ${LSTACK_BUCKET} --acl public-read >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3api put-object-acl --bucket ${LSTACK_BUCKET} --key s3_test_data_development.json --grant-full-control uri=http://acs.amazonaws.com/groups/global/AllUsers >> /tmp/localstack_infra.log

        #To copy files into s3 localstack
        echo -e "Copying s3_test_data_development content to $DATADIR/local_data" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 cp ${DATADIR}/local_data/s3_test_data_development.json s3://${LSTACK_BUCKET}/ >> /tmp/localstack_infra.log

        #To list the files in s3
        echo -e "Lising content of $LSTACK_BUCKET" >> /tmp/localstack_infra.log
        aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT} s3 ls s3://${LSTACK_BUCKET} >> /tmp/localstack_infra.log
    elif [ $service_th == 'kinesis' ]
    then
        awslocal cloudformation create-stack --template-body file://${DATADIR}/templates/kinesistemplate.yml --stack-name teststack >> /tmp/localstack_infra.log
        # Select http or https
        HTTP_PROTOCOL="http"
        SSL_FLAG=""
        if [ $USE_SSL ]
        then
            HTTP_PROTOCOL="https"
            SSL_FLAG="--no-verify-ssl"
        fi
        echo -e "Configurint PROTOCOL $HTTP_PROTOCOL and SSL FLAG $SSL_FLAG" >> /tmp/localstack_infra.log
        read -ra STREAMS_NAMES_TOKENS <<< "$STREAMS_NAMES"
        STREAMS_NAMES_TOKENS_FORMATED=()
        if [ -z "$NUMBER_STREAMS" ]
        then
            STREAMS_NAMES_TOKENS_FORMATED=("${STREAMS_NAMES_TOKENS[@]}")
        else
            read -ra NUMBER_STREAMS_TOKENS <<< "$NUMBER_STREAMS"
            index=0;
            for stream_token_number_th in "${NUMBER_STREAMS_TOKENS[@]}"; do
                for (( stream_th=1; stream_th<=$stream_token_number_th; stream_th++ )); do
                    STREAM_NAME_VALUE=${STREAMS_NAMES_TOKENS[$index]}
                    if [[ $stream_token_number_th > 1 ]]
                    then
                        STREAM_NAME_VALUE=${STREAM_NAME_VALUE/@/$stream_th}
                    fi
                    STREAMS_NAMES_TOKENS_FORMATED+=($STREAM_NAME_VALUE)
                done
                $((++index))
            done
        fi
        for stream_name_formated in "${STREAMS_NAMES_TOKENS_FORMATED[@]}"; do
            echo -e "Creating on ${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} stream ${ENVIRONMENT_NAME}.${stream_name_formated}" >> /tmp/localstack_infra.log
            aws kinesis ${SSL_FLAG} create-stream --endpoint-url=${HTTP_PROTOCOL}://${LSTACK_HOST}:${LSTACK_KINESIS_PORT} --stream-name "${ENVIRONMENT_NAME}.${stream_name_formated}" --shard-count 1  >> /tmp/localstack_infra.log
        done
    elif [ $service_th == 'dynamodb' ]
    then
        awslocal cloudformation create-stack --template-body file://${DATADIR}/templates/dinamodbtemplate.yml --stack-name teststack >> /tmp/localstack_infra.log
    fi
done

