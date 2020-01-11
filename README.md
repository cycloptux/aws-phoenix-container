# Phoenix Application Problem - Proposed Solution
The code contained in this repository represents a possible solution to creating a production ready infrastructure for the Phoenix Application.

## Assumptions & Requirements

- Terraform is installed in the system running this code (the tests were made on a Ubuntu 16.04 LTS server running Terraform 0.12.19).
- Amazon Web Services is being used as XaaS provider.
- US East (Ohio) (us-east-2) will be used as deployment Region, but can be configured in ./terraform/variables.tf.
- t3.small (2 vCPU, 2 GiB RAM) instances are used, but can be configured in ./terraform/variables.tf.
- Proper AWS credentials (and IAM authorizations) are configured.


## Environment Variables Setup
```
export TF_VAR_key_name={Name of the IAM key set}

```