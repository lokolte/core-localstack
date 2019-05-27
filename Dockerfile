FROM mhart/alpine-node:5.11

LABEL "com.weightwatchers.core"="LocalStack Incorporated"
LABEL version="1.0"
# TODO ask if this mail exist
LABEL maintainer="core-services@weightwatchers.com"
# TODO remplace kinesalite with localstack and use the port 4567
EXPOSE 8080 8055 4572 443 80

ENV DATADIR /var/lib/localstack

## temporal variables
ENV LSTACK_HOST localstack-server
ENV LSTACK_PORT 4572
ENV LSTACK_BUCKET demo-bucket
ENV LSTACK_SERVICES s3

#ENV AWS_DEFAULT_REGION us-east-1
ENV AWS_ACCESS_KEY_ID foo
ENV AWS_SECRET_ACCESS_KEY foo

# Variables for localstack services
ENV LOCALSTACK_SERVICES $LSTACK_SERVICES
ENV LOCALSTACK_DEBUG 1
ENV LOCALSTACK_DATA_DIR /var/lib/localstack/data
ENV LOCALSTACK_DEFAULT_REGION us-east-1
ENV LOCALSTACK_HOSTNAME core-localstack

# Dependencies for localstack
RUN apk --no-cache update && \

    apk --no-cache add bash && \
    apk --no-cache add openjdk8-jre && \
    apk --no-cache add python3 python3-dev libstdc++ openssl-dev linux-headers libffi-dev clang make g++ gcc curl groff less && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 --no-cache-dir install --upgrade pip wheel && \
    pip3 --no-cache-dir install -U setuptools && \
    pip3 --no-cache-dir install psutil awscli urllib3 python-coveralls cfn-lint==0.20.0 && \
    rm -rf /var/cache/apk/*

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/jre
ENV PATH $PATH:$JAVA_HOME/bin

ENV MAVEN_VERSION 3.5.4

RUN wget http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} /usr/lib/mvn

ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $PATH:$MAVEN_HOME/bin

RUN mkdir $DATADIR

ENV ELASTIC_VERSION 7.1.0

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    tar -zxvf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    rm elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    mv elasticsearch-${ELASTIC_VERSION} $DATADIR

ENV ES_HOME ${DATADIR}/elasticsearch-${ELASTIC_VERSION}
ENV PATH $PATH:$ES_HOME/bin

RUN ls $DATADIR

RUN ls ${DATADIR}/elasticsearch-${ELASTIC_VERSION}/bin

RUN ${DATADIR}/elasticsearch-${ELASTIC_VERSION}/bin/elasticsearch-plugin install analysis-icu

RUN pip3 --no-cache-dir install localstack && \
    pip3 --no-cache-dir install --upgrade localstack

WORKDIR $DATADIR

VOLUME $DATADIR

COPY local_data/test_data.part ${DATADIR}/data/test_data.part
COPY scripts/localstack_init.sh ${DATADIR}/localstack_init.sh
COPY scripts/init.sh ${DATADIR}/init.sh

CMD ["./localstack_init.sh"]
