ARG  LOCALSTACK_DOCKER_IMAGE_TAG=latest
FROM localstack/localstack:$LOCALSTACK_DOCKER_IMAGE_TAG

ENV DATADIR /var/lib/core-localstack

## temporal variables
ENV LSTACK_HOST localhost
ENV LSTACK_PORT 4572
ENV LSTACK_BUCKET demo-bucket
ENV LSTACK_SERVICES s3
ENV LSTACK_HOSTNAME core-localstack
ENV LSTACK_REGION us-east-1

#ENV AWS_DEFAULT_REGION us-east-1
ENV AWS_ACCESS_KEY_ID foo
ENV AWS_SECRET_ACCESS_KEY foo

RUN mkdir $DATADIR
RUN mkdir $DATADIR/scripts
RUN mkdir $DATADIR/data

COPY resources $DATADIR

RUN chmod +x ${DATADIR}/scripts/init.sh
RUN chmod +x ${DATADIR}/initialize.sh

COPY resources/local_data/test_data.part ${DATADIR}/data/test_data.part

RUN pip install awscli-local

# We run the init script as a health check
# That way the container won't be healthy until it's completed successfully
# Once the init completes we wipe it to prevent it continiously running
HEALTHCHECK --start-period=10s --interval=1s --timeout=3s --retries=30\
  CMD ${DATADIR}/initialize.sh
