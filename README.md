# aws-cis-level1-automation
We build a baseline automation solution to ensure compliance with  CIS AWS Foundations Benchmark level 1 compliance, to protect organizations against the indelible reality of high severity cloud cyber attack.

## a. Prerequisites

1. **Coding**  
   - Install Visual Studio Code (VSC) or any preferred code development tool.  
   - Create a branch for each development feature and merge into the `main` branch via pull requests.

2. **Git / GitHub**  
   - Create a GitHub account and install Git on your local machine or dev environment.  
   - Configure credentials to clone, push, and pull code to/from the remote repo.

3. **AWS**  
   - Sign up for a free-tier AWS account following best security practices.  
   - Create an **admin** account with full privileges, then use it to create a **dev** user with least-privilege access.  
   - Generate and securely store access keys (do _not_ use your root account).  
   - Install and configure the AWS CLI locally in VSC with your dev user’s access keys.  
   - In the AWS Console, create a CloudWatch Log Group named:
     - `/aws/cloudtrail/logs/`
       
   - Delete any existing IAM roles named:
     - `aws-config-role`
     - `cis1_1-contact-check-role*`

4. **Terraform**  
   - Download and install Terraform in your dev environment.  
   - Verify it’s properly configured to work with your AWS credentials.

## Architecture
We built the architecture below for our solution, using AWS services. Our solution uses three main design patterns to automate compliance:

1. Controls detected by setting up AWS config Managed rule. Example: CIS 1.3 Ensure no 'root' user account access key exists
2. Controls detecting a particular event, generating cloudwatch alarms, and alerts for review and remediation. Example: CIS 4.3 Ensure usage of the 'root' account is monitored 
3. Controls continuously checking if manual configuration is set-up, based on a cron event driven pattern, and alerts for manual remediation. Example: CIS 1.1  Maintain current contact details 

here is the architecture for this end-to-end automation: ![Architecture - CIS AWS Foundations Benchmarks Level 1 Automation](./assets/images/awsarchiteeeeturecompliance-fineleventb.png)

## Use

## Clean-UP

## Copyright