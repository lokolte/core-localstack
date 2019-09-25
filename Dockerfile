FROM localstack/localstack:0.9.4

ENV DATADIR /var/lib/core-localstack

ENV AWS_CONFIG /root/.aws

EXPOSE 8080 8055 4568 4569 4572 80

RUN mkdir $DATADIR
RUN mkdir $DATADIR/scripts
RUN mkdir $DATADIR/data
RUN mkdir $AWS_CONFIG

COPY resources $DATADIR
COPY resources/config $AWS_CONFIG

RUN chmod +x ${DATADIR}/scripts/init.sh
RUN chmod +x ${DATADIR}/initialize.sh

VOLUME $DATADIR

# We run the init script as a health check
# That way the container won't be healthy until it's completed successfully
# Once the init completes we wipe it to prevent it continiously running
HEALTHCHECK --start-period=20s --interval=1s --timeout=5s --retries=10 CMD ${DATADIR}/initialize.sh
