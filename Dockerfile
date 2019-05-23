FROM mhart/alpine-node:5.11

LABEL "com.weightwatchers.core"="LocalStack Incorporated"
LABEL version="1.0"
# TODO ask if this mail exist
LABEL maintainer="core-services@weightwatchers.com"
# TODO remplace kinesalite with localstack and use the port 4567
EXPOSE 8080 8055 4572 443 80

ENV DATADIR /var/lib/localstack

ENV AWS_DEFAULT_REGION 'us-east-1'
ENV AWS_ACCESS_KEY_ID 'foo'
ENV AWS_SECRET_ACCESS_KEY 'foo'

ENV SERVICESs s3
#${LOCALSTACK_SERVICES}
ENV LOCALSTACK_DEBUG 1
ENV LOCALSTACK_DATA_DIR ${DATADIR}/data
ENV LOCALSTACK_DEFAULT_REGION ${AWS_DEFAULT_REGION}
#ENV LOCALSTACK_HOSTNAME=core-localstack

ENV AWS_CLI_VERSION 1.11.131

RUN echo $SERVICESs $LOCALSTACK_DATA_DIR $AWS_CLI_VERSION $DATADIR

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools && \
    pip --no-cache-dir install --upgrade pip && \
    pip --no-cache-dir install awscli==${AWS_CLI_VERSION} && \
    pip --no-cache-dir install localstack && \
    rm -rf /var/cache/apk/*

RUN mkdir -p $DATADIR

WORKDIR ${DATADIR}

COPY /scripts/init.sh ${DATADIR}/init.sh

VOLUME $DATADIR

CMD ["./init.sh"]