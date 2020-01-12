# Phoenix Application Problem - Proposed Solution

The code contained in this repository represents part of a possible solution to creating a production ready infrastructure for the Phoenix Application.

## Assumptions & Requirements

- Terraform is installed in the system running this code (the tests were made on a Ubuntu 16.04 LTS server running Terraform 0.12.19).
- Amazon Web Services is being used as XaaS provider.
- US East (Ohio) (us-east-2) will be used as deployment Region, but can be configured in ./terraform/variables.tf.
- t3.small instances are used for ECS, but can be configured in ./terraform/variables.tf.
- db.r5.large instances are used for DocumentDB, but can be configured in ./terraform/variables.tf.
- Proper AWS credentials (and IAM authorizations) are configured.


## Environment Variables Setup

```
export AWS_ACCESS_KEY_ID={AWS Account ID}
export AWS_SECRET_ACCESS_KEY={AWS Account Secret}
export AWS_DEFAULT_REGION={AWS Region Used}
export TF_VAR_ssh_public_key={Public key material of a generated key pair}
export TF_VAR_admin_cidr_ingress={CIDR to allow tcp/22 ingress to EC2 instances}
export TF_VAR_docdb_password={Master password for the DocumentDB cluster}
```

## Solution Architecture

This solution uses [Terraform](https://www.terraform.io/) to build an architecture in Amazon Web Services using a mix of managed and IaaS services.

The Phoenix Application is containerized through a Dockerfile, and started on an Elastic Container Service cluster on AWS.

PaaS/managed services are specifically preferred to ease the setup and management of the infrastructure, and to natively support some of the requirements asked by the problem.

Once the above environment variables are set, the infrastructure can be started by running:

```
cd terraform
terraform apply
```

This Terraform plan starts the following components:

### Basic Network and Computing Environment

- A new VPC is created in the selected region, and 3 subnets are allocated on the 3 different AZs.
- An internet gateway is activated in order to connect to the infrastructure. This may be replaced by a Site-to-Site VPN in a real production environment.
- A generic Auto Scaling Group is created, to be further configured.
- Proper security groups are allocated. These enable access to the infrastructure from the internet, and are to be hardened when the testing phase is over.
- Proper IAM roles are configured to enable the basic interaction between services.

### Database: DocumentDB

[DocumentDB](https://aws.amazon.com/documentdb/), the MongoDB-compatible NoSQL Database managed by AWS, is used as backend.

DocumentDB is only compatible to MongoDB up to v3.6, which is enough to cover the application requirements. A proper setup of MongoDB Atlas (or a self-managed MongoDB Enterprise) is suggested for a production environment if MongoDB is chosen as main Database for further developments.

DocumentDB is configured as a "Replica Set" using 3 instances. This ensures a High-Availability setup. Its storage is also encrypted to comply with the basic security compliance frameworks.

The Database is backed up every night (around 1:00-3:00 AM UTC), and the (encrypted) backup snapshots are kept for 30 days.

### Container Repository: ECR

An ECR (Elastic Container Repository) is allocated. This private repository will store the Docker images built from the Phoenix Application source code.

Depending on the frequency (and specific configuration) of updates, Docker images are kept for 14 days (if new updates are "untagged") or, alternatively, deleted after 30 new image versions.

### Container Platform: ECS

An ECS (Elastic Container Service) cluster is started. The cluster is configured to have 2 to 4 servers (in order to enable a HA setup and support scaling).

By default, each service is started in a HA setup as well, with a minimum of 2 instances per "task".

An empty task is configured, the task will be linked to the Phoenix Application Docker image.

### Load Balancing: ELB/ALB

Since the ECS platform is configured to have more than one instance of a service per task definition, an Application Load Balancer is configured in front of the services.

### Logging: CloudWatch Logs

In order to enable a proper logging of events generated by the application, the ECS cluster is configured to export logs to a specific group of CloudWatch Logs. These logs are retained for 30 days, then deleted.

## Solution Description

Upon starting the infrastructure, the Terraform script will expose the endpoints of the allocated ECR repository and DocumentDB cluster, and the ELB public DNS to access the application running on cluster from the internet.

The ECR repository URL can be added in the `buildspec.yml` file as `REPOSITORY_URI` variable.

The application may be then hosted on GitHub or a private CodeCommit repository. A properly configured CodeBuild project can then monitor GitHub or CodeCommit new commits and automatically start building the new Docker image, which will be sent to the newly created ECR repository. In order to do this, the CodeBuild project must be configured with CodeCommit or GitHub as source provider.

Once the build is done, the Docker image will be flagged as "latest" on the ECR repository, and can then deployed "manually" through a new deployment in ECS, or automatically through a Blue-Green approach.

This step can eventually be automated by setting up a full CodePipeline.

Through the use of the ECS platform, application crashes are immediately recovered as long as a health endpoint is added to the application itself. The health check can be as simple as adding this additional endpoint to one of the routes:

```
// Elastic Load Balancer Health Check
app.get("/health", (req, res, next) => { res.status(200).send("healthy"); });
```

In order to block the `GET /crash` and block (or rate limit) the `GET /generatecert` endpoints, an API Gateway can be added in front of the actual application by redirecting the ALB to the API Gateway. The newly released HTTP APIs API Gateway offers this set of features for a cheaper price than the full RESTful APIs Gateway.

Scaling can be achieved by monitoring the number of requests either on the ELB, or on the API Gateway. The ECS task can then be configured to start more service instances when it received an event from CloudWatch Events.

CPU resources can be monitored through the CloudWatch dashboard, or through the configuration of CloudWatch Events that are sent through an external monitoring service. CloudWatch can be configured to notify the user through multiple channels when the average CPU in a certain time span goes over a threshold.

## Requirements Checklist

- [x] Automate the creation of the infrastructure and the setup of the application. - Done through the Terraform script.
- [x] Recover from crashes. Implement a method autorestart the service on crash - Done through the Dockerization and use of ECS.
- [x] Backup the logs and database with rotation of 7 days - Done through the use of DocumentDB auto-backups and CloudWatch Logs.
- [x] Notify any CPU peak - This is not implemented, but designed through the use of CloudWatch Events.
- [x] Implements a CI/CD pipeline for the code - This is not implemented, but designed through the use of CodeBuild + CodeDeploy + CodePipeline.
- [x] Scale when the number of request are greater than 10 req /sec - This is not implemented, but designed through the use of the Auto Scaling Group / ECS Task Scaling configurations and events coming from the ELB or API Gateway.