# Initialised Localstack
This image extends the functionality of the default image provided by the awesome [localstack](https://github.com/localstack/localstack).

In a nutshell, localstack enables you to run a number of AWS services locally for testing.

This image extends that functionality to allow you to start the image fully initialised with your configuration. For example Kinesis Streams, SQS queues, Dynamo Tables, etc.

You can do this by providing either a CloudFormation template or a script running `awslocal` Cli commands.

## Versions
The tagged versions pull the corresponding localstack image. For example, 0.7.4 pulls localstack 0.7.4.

## Running
`docker-compose up` will start the stack with the services defined by `SERVICES` in the `docker-compose.yml` or `LOCALSTACK_SERVICES` in the `.env` overrides.

## Bootstrapping
Scripts are copied to `/opt/bootstrap/scripts`.

Templates are copied to `/opt/bootstrap/templates`.

By default the `init.sh` script creates an AWS stack using the CloudFormation template located in `/opt/bootstrap/templates`.

Note that the CloudFormation template functionality provided by localstack isn't feature complete, [this](https://github.com/localstack/localstack/tree/master/tests/integration/templates) example `test` templates directory from localstack gives an indication of the currently supported featureset.

## Healthcheck
The image runs the bootstrapping scripts as a health check. This means that the service isn't considered `healthy` until they complete. This can therefore be used to control startup order within docker compose (see example below). **Do not override the health check!**

### Runtime overrides
Two options for overriding this at runtime:
- To just use a different CloudFormation template mount a Volume over `/opt/bootstrap/templates` containing a `cftemplate.yaml` template.
- To directly use `awslocal` on the Cli, mount a Volume over `/opt/bootstrap/scripts` containing an `init.sh` script.

[awslocal](https://github.com/localstack/awscli-local) is installed and used for bootstrapping scripts.

# docker-compose
Here's an example compose file for running the container with kinesis, dynamodb, cloudwatch & Cloudformation. Startup order is controlled using `depends_on`.
This mounts over the `cftemplate.yml` with a template in the same directory as the compose file:

```yaml
version: "2.3"

services:
  localstack:
    image: markglh/initialised-localstack:latest
    environment:
      - "SERVICES=${LOCALSTACK_SERVICES:-kinesis,dynamodb,cloudwatch,cloudformation}"
      - "DEFAULT_REGION=${AWS_REGION:-us-east-1}"
      - "HOSTNAME=${LOCALSTACK_HOSTNAME:-localhost}"
      - "HOSTNAME_EXTERNAL=${LOCALSTACK_HOSTNAME_EXTERNAL:-localhost}"
      - "USE_SSL=true"
      #- "DATA_DIR=${LOCALSTACK_DATA_DIR:-/tmp/localstack/data}" # uncomment if you want to persist data between runs
    volumes:
      - ./templates:/opt/bootstrap/templates
    ports:
      - "4567-4582:4567-4582"
      - "8080:8080"

  some-service:
    image: myorg/some-service
    depends_on:
      localstack:
        condition: service_healthy
```

Note that the environment variables supply default values but can be overridden using a `.env` file.

# Example query against the container
From your host, either install `awslocal` or pass the appropriate endpoint overrides to the aws Cli.

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
