# aws-solution-examples
A template for quickly spinning up an AWS full stack

### Tech Stack
[AWS](https://console.aws.amazon.com) | [Terraform](https://www.terraform.io/downloads.html) | [AWS Amplify Framework](https://docs.amplify.aws/cli/start/install)

![Build Status](https://codebuild.us-east-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiZTRiOEpFenJqRDlaN25CZkVNWU8rNjVrYkFXMkJCRktBSFhNT1A2cHlIbEhvOWc4RUEvY2FuR0lUUDd6Zmw3NXh2U3hYOG80ajRSc2FTR0ROWEhXM1hjPSIsIml2UGFyYW1ldGVyU3BlYyI6Iis2OEN6SHJHVW5zb0syMEciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)


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
* Configuration of React app located in `frontend` dir. 
* Create a simple web application using AWS Amplify [guide](https://aws.amazon.com/getting-started/hands-on/build-react-app-amplify-graphql/)