FROM localstack/localstack:latest

ENV DATADIR /var/lib/core-localstack

EXPOSE 8080 4567-4582 80

RUN mkdir $DATADIR
RUN mkdir $DATADIR/scripts
RUN mkdir $DATADIR/data

COPY resources $DATADIR

RUN chmod +x ${DATADIR}/scripts/init.sh
RUN chmod +x ${DATADIR}/initialize.sh

VOLUME $DATADIR

# We run the init script as a health check
# That way the container won't be healthy until it's completed successfully
# Once the init completes we wipe it to prevent it continiously running
HEALTHCHECK --start-period=10s --interval=1s --timeout=3s --retries=30 CMD ${DATADIR}/initialize.sh