# core-localstack

core-localstack layer dependency for anonymization-feeder, ....

Core-localstack Container =  localstack + Aws-Cli

## Kinesalite

Container based on: https://github.com/mhart/kinesalite

## Aws Cli 

Set up config & Credentiales

## Core User Profile Service

Setup your local.conf file

    kinesis {
    
      application-name = "core-profile-service"
    
      aws.profile = "ww"
    
      profile-producer {
        kpl {
          Region = us-east-1
          MetricsLevel = none
          KinesisEndpoint = "kinesalite"
          KinesisPort = 4567
          VerifyCertificate = false
          LogLevel = "error"
        }
      }
    
    }
  
    feature.kinesis = true


## Run docker compose 

    docker-compose -f test/user-profile.yml -f local/user-profile.yml up

## Connect kinesalite container and create necessary streams

- kinesalite is running in ssl mode, 
- profile kinesalite use a certificate, see details on config file

```
    $ docker ps
        
    CONTAINER ID        IMAGE                                                         COMMAND                  CREATED             STATUS              PORTS                                                                    NAMES
    b7667f9433d9        nginx                                                         "nginx -g 'daemon ..."   5 minutes ago       Up 5 minutes        0.0.0.0:9000->80/tcp                                                     test_nginx_1
    2a4390002d57        quay.io/weightwatchers/core-sbt-docker:1.0.0                  "sbt -jvm-debug 50..."   5 minutes ago       Up 5 minutes        0.0.0.0:5005->5005/tcp, 0.0.0.0:9001->80/tcp                             test_user-profile.core_1
    e5d09a0ab303        quay.io/fernandotorterolo/core-kinesalite                     "./cmd.sh"               5 minutes ago       Up 5 minutes        0.0.0.0:443->443/tcp, 0.0.0.0:4567->4567/tcp                             test_core-kinesalite_1
    bc361252227a        cassandra:2.1                                                 "/docker-entrypoin..."   2 days ago          Up 5 minutes        7000-7001/tcp, 7199/tcp, 9160/tcp, 0.0.0.0:9044->9042/tcp                test_cassandra-node3_1
    4ba9263bf0a8        cassandra:2.1                                                 "/docker-entrypoin..."   2 days ago          Up 5 minutes        7000-7001/tcp, 7199/tcp, 9160/tcp, 0.0.0.0:9043->9042/tcp                test_cassandra-node2_1
    bf96deebe334        cassandra:2.1                                                 "/docker-entrypoin..."   2 days ago          Up 5 minutes        7000-7001/tcp, 7199/tcp, 9160/tcp, 0.0.0.0:9042->9042/tcp                test_cassandra-node1_1
    977b72f248dd        quay.io/weightwatchers/core-mock-enterprise-service:develop   "/docker-entrypoin..."   2 days ago          Up 5 minutes        9000/tcp, 9999/tcp, 0.0.0.0:9902->80/tcp                                 test_mule.es_1
    bed52a5e4ba7        quay.io/weightwatchers/opendj:2.1.0                           "/opt/opendj/run.sh"     2 days ago          Up 5 minutes        0.0.0.0:1389->1389/tcp, 0.0.0.0:1636->1636/tcp, 0.0.0.0:4444->4444/tcp   test_core-ldap-container_1
    
    11:01 $ docker exec -it test_core-kinesalite_1 /bin/ash

    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.ProfileEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.ProgramEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.JournalEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.ActivityEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.FoodEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.QuickAddFoodEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567
    test_core-kinesalite_1:$ aws kinesis create-stream --stream-name local.core-profile-service.1.WeightEvent --shard-count 1 --profile kinesalite --endpoint-url https://kinesalite:4567

```

- create stream over http.

kinesalite should be container ip.
shard-count default value = 1

```
    $ curl -X PUT http://kinesalite/stream/local.core-profile_test_1
    $ curl -X PUT http://kinesalite/stream/local.core-profile_test2?shard-count=2

```

### list streams

``` 
    $ aws kinesis list-streams --profile kinesalite --endpoint-url https://kinesalite:4567
```

## Validate Core-kinesis (reactive-kinesis) properties


    user-profile.core_1    .... [info] [logging.cc:83] Set boost log level to info
    user-profile.core_1    .... [info] [logging.cc:170] Set AWS Log Level to WARN
    user-profile.core_1    .... [info] [main.cc:346] Setting CA path to /tmp/amazon-kinesis-producer-native-binaries
    user-profile.core_1    .... [info] [main.cc:382] Starting up main producer
    user-profile.core_1    .... [info] [kinesis_producer.cc:87] Using Region: us-east-1
    user-profile.core_1    .... [info] [kinesis_producer.cc:140] Using Kinesis endpoint kinesalite:4567
    user-profile.core_1    .... [info] [kinesis_producer.cc:87] Using Region: us-east-1
    user-profile.core_1    .... [info] [kinesis_producer.cc:48] Using default CloudWatch endpoint
    user-profile.core_1    .... [info] [main.cc:393] Entering join

## Produce events


    user-profile.core_1    | 2017-09-10 14:14:18,837 [trace] p.ProfileProducer - Pushing to kinesis:
    user-profile.core_1    | {"headers":{"messageId":"5537f031-9632-11e7-bba5-c9058229306d","source":"core-user-profile","action":"Create"},"payload":{"classicLocale":"en-US","classicCountry":"US","username":"#X#X#","referralId":"SOMEIDCODE2","promotionId":"OPRAH","title":"Mr.","firstName":"#X#X#","middleInitial":"#X#X#","lastName":"#X#X#","birthDate":"#X#X#","gender":"F","height":152,"address":{"home":{"streetAddress":"#X#X#","extendedAddress":"#X#X#","postOfficeBox":"#X#X#","locality":"#X#X#","region":"#X#X#","postalCode":"#X#X#","country":"#X#X#","latitude":0,"longitude":0},"shipping":{"streetAddress":"#X#X#","extendedAddress":"#X#X#","postOfficeBox":"#X#X#","locality":"#X#X#","region":"#X#X#","postalCode":"#X#X#","country":"#X#X#","latitude":0,"longitude":0}},"phone":{"home":"#X#X#","cell":"#X#X#"},"email":{"personal":"#X#X#"},"identity":{"classic":248698,"facebook":8597},"acquisitionId":"#X#X#","communicationPreferences":["mail"],"preferredHeightWeightUnits":"metric","newletterOption":false,"referrerSite":"yahoo","sendRegisterationEmail":true,"zipWork":"#X#X#","avatarUrl":"#X#X#","fullProfileUrl":"172.16.1.10/profile/bf8923e6-0748-4dae-8819-83ccac3dc0f9?cachingTimestamp=1505052857527","userId":"bf8923e6-0748-4dae-8819-83ccac3dc0f9"}}
    user-profile.core_1    | 2017-09-10 14:14:19,106 [debug] access - http result 200 on POST /profile?skipES=true&overrideRegistrationDate= with headers: Map()
    user-profile.core_1    | 2017-09-10 14:14:19,390 [trace] c.w.c.e.p.KinesisProducerActor - Succesfully sent message to kinesis: ProducerEvent(bf8923e6-0748-4dae-8819-83ccac3dc0f9,java.nio.HeapByteBuffer[pos=1229 lim=1229 cap=1229])
    user-profile.core_1    | 2017-09-10 14:14:19,428 [trace] p.ProfileProducer - Successfully sent ProducerEvent(55e06532-9632-11e7-bba5-a7bfacd119ef)
    user-profile.core_1    | 2017-09-10 14:14:19,530 [trace] c.d.d.c.Connection - Connection[cassandra/172.16.1.2:9042-2, inFlight=1, closed=false], stream 576, writing request QUERY INSERT INTO core_user_profile_service.registration_changes (date, hour, timestamp, userId, classicCountry, classicLocale, birthDate, gender, height, preferredHeightWeightUnits, registrationDate) VALUES(20170910, 14, 1505052858143, bf8923e6-0748-4dae-8819-83ccac3dc0f9, 'US', 'en-US', '1970-10-10', 'F', 152, 'metric', 1505052846058) USING TTL 7776000;([cl=LOCAL_QUORUM, positionalVals=[], namedVals={}, skip=false, psize=5000, state=null, serialCl=SERIAL])