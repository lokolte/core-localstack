#!/bin/sh

echo -e "Starting localstack server for $LOCALSTACK_SERVICES"

#npm -version

#node -version

#echo $ES_HOME

#ls -la /var/lib/localstack/elasticsearch-${ELASTIC_VERSION}

#ls /var/lib/localstack/elasticsearch-${ELASTIC_VERSION}/bin/

#echo "Fin debug versions"

localstack start && ./init.sh