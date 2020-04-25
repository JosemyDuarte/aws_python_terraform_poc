# Python Serverless + Terraform PoC

I was curious about Terraform, so I decided to build something with it. 

This would be the requirements:
 
 1. One function that should be able to download the source code a web page 
 2. One function that should save that content in a S3 bucket. 
 3. The communication between both lambda should be through SQS or SNS.
 
So I would have to learn about deployment of packages, creation of resources and permissions with Terraform.

---

#### How to build it?
```shell script
terraform apply
```
#### How to clean everything?
```shell script
terraform destroy
```
