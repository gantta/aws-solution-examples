# aws-solution-examples
A template for quickly spinning up an AWS full stack

### Tech Stack
[AWS](https://console.aws.amazon.com) | [Terraform](https://www.terraform.io/downloads.html) | [AWS Amplify Framework](https://docs.amplify.aws/cli/start/install)


## Getting Started with Terraform
For local devlopment and testing

All infrastructure code will reside within the `Terraform` dir.

Create a `envVariables.tfvars` file in the root directory with the following variables:

    AWS_ACCESS_KEY_ID=""
    AWS_SECRET_ACCESS_KEY=""
    GITHUB_PAT=""

1.	`cd .\Terraform\`
2.  `terraform init`
3.	`terraform plan -var-file="envVariables.tfvars"`
4.	`terraform apply -var-file="envVariables.tfvars"`
5.	`terraform destroy -var-file="envVariables.tfvars"`

## Getting Started with AWS Amplify Framework

* Install the latest Amplify CLI version
    `npm install -g @aws-amplify/cli`
* Follow this [guide](https://docs.amplify.aws/cli/start/install#configure-the-amplify-cli) to configure Amplify