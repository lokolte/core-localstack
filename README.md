# Initialised Localstack
This image extends the functionality of the default image provided by the awesome [localstack](https://github.com/localstack/localstack).

In a nutshell, localstack enables you to run a number of AWS services locally for testing.

This image extends that functionality to allow you to start the image fully initialised with your configuration. For example Kinesis Streams, SQS queues, Dynamo Tables, etc.

You can do this by providing either a CloudFormation template or a script running `awslocal` Cli commands.

## Versions
The tagged versions pull the corresponding localstack image. For example, 0.7.4 pulls localstack 0.7.4.

## Running
`docker-compose up` will start the stack with the services defined by `SERVICES` in the `docker-compose.yml` or `LSTACK_SERVICES` in the `.env` overrides.

## Bootstrapping
Scripts are copied to `/var/lib/core-localstack/scripts`.

Templates are copied to `/var/lib/core-localstack/templates`.

By default the `init.sh` script creates an AWS stack using the CloudFormation template located in `/var/lib/core-localstack/templates` depending of the service, add yours to `/resources/scripts/init.sh` and create the template in `/resources/templates` folder.

Note that the CloudFormation template functionality provided by localstack isn't feature complete, [this](https://github.com/localstack/localstack/tree/master/tests/integration/templates) example `test` templates directory from localstack gives an indication of the currently supported featureset.

## Healthcheck
The image runs the bootstrapping scripts as a health check. This means that the service isn't considered `healthy` until they complete. This can therefore be used to control startup order within docker compose (see example below). **Do not override the health check!**

### Runtime overrides
Two options for overriding this at runtime:
- To just use a different CloudFormation template mount a Volume over `/var/lib/core-localstack/templates` containing a `s3template.yaml` template and all defined here.
- To directly use `awslocal` on the Cli, replace the `aws --endpoint-url=http://${LSTACK_HOST}:${LSTACK_PORT}` by `awslocal` in `/var/lib/core-localstack/scripts` for the `init.sh` script.

[awslocal](https://github.com/localstack/awscli-local) is installed in DockerFile and used for bootstrapping scripts in `/var/lib/core-localstack/scripts/init.sh`.

# docker-compose
Here's an example compose file for running the container with s3, kinesis and dynamodb. Startup order is controlled using `depends_on`.

```yaml
version: "2.3"

services:
  core-localstack:
    image: quay.io/weightwatchers/core-localstack:master
    environment:
      - "SERVICES=${LSTACK_SERVICES:-s3,kinesis,dynamodb}"
      - "DEFAULT_REGION=${LSTACK_REGION:-us-east-1}"
      - "HOSTNAME=${LSTACK_HOSTNAME:-localhost}"
      #- "HOSTNAME_EXTERNAL=${LSTACK_HOSTNAME_EXTERNAL:-localhost}"
      #- "USE_SSL=true"
      #- "DATA_DIR=${LSTACK_DATA_DIR:-/tmp/core-localstack/data}" # uncomment if you want to persist data between runs 
    ports:
      - "4567-4582:4567-4582"
      - "8080:8080"

  some-service:
    image: myorg/some-service
    depends_on:
      core-localstack:
        condition: service_healthy
```

Note that the environment variables supply default values but can be overridden using a `.env` file.

# Example query against the container
From your `/resources/scripts/init.sh`, either install `awslocal` or pass the appropriate endpoint overrides to the aws Cli, after configured a template for kinesis stream and added to the stack.

```bash
aws --endpoint-url=https://localhost:4568 kinesis --profile=personal --no-verify-ssl list-streams                                                   

InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised. See: https://urllib3.readthedocs.org/en/latest/security.html
  InsecureRequestWarning)
{
    "StreamNames": [
        "int-test-stream-1",
        "int-test-stream-2"
    ]
}
```

For s3 either using `awscli`.

```bash
aws --endpoint-url=http://localhost:4572 s3 ls s3://demo-bucket

2019-05-28 19:04:54      52360 s3_test_data.part
```

# Example of kinesis stream template
From your host, either install `awslocal` or pass the appropriate endpoint overrides to the aws Cli.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: CloudFormation Int Test Template
Resources:
  KinesisStream1:
    Type: AWS::Kinesis::Stream
    Properties:
      Name: int-test-stream-1
      ShardCount: 1
  KinesisStream2:
    Type: AWS::Kinesis::Stream
    Properties:
      Name: int-test-stream-2
      ShardCount: 1
```