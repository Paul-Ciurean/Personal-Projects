# WordPress Deployed Using DevOps Principles

![project-image](/Project-8-WP-Deployed-On-ECS/images/project-image.png)

## Overview: 

### In this project, we leverage DevOps principles to deploy a robust and scalable WordPress website on AWS infrastructure. Utilizing Terraform for infrastructure as code (IaC), we automate the provisioning of a comprehensive suite of AWS services, from the networking layer to advanced storage and compute solutions. The deployment includes AWS VPC for network isolation, Amazon ECR for container image storage, ECS Fargate for container orchestration, Amazon EFS for scalable file storage, and Amazon RDS for managed database services.

### To ensure continuous integration and continuous deployment (CI/CD), we incorporate GitHub Actions. This automation tool pulls the latest WordPress image from the repository, tags it, and pushes it to Amazon ECR, streamlining the update process and maintaining the integrity and security of the application.

## **Key Components:**

- **Terraform:** Automates the deployment of AWS resources.
- **Amazon VPC:** Provides network isolation and security.
- **Amazon ECR:** Stores and manages container images.
- **Amazon ECS Fargate:** Orchestrates container deployment without managing servers.
- **Amazon EFS:** Offers scalable and shared file storage.
- **Amazon RDS:** Manages relational databases efficiently.
- **GitHub Actions:** Implements CI/CD pipelines for automated image handling.

## **Benefits**

1. **Automation:** Reduces manual intervention and human error, making the deployment process faster and more reliable.
2. **Scalability:** Ensures that the infrastructure can scale according to the needs of the application.
3. **Consistency:** Terraform ensures that the infrastructure is consistent across different environments.
4. **Security:** AWS services like VPC and IAM enhance the security of the deployment.
5. **Efficiency:** CI/CD pipeline automates the process of updating and deploying the WordPress site.

## **Issues Faced and Solutions**

## **Issue 1:**

### **Problem:** Forgot to set `map_public_ip_on_launch`, resulting in resources not having internet connectivity.
### **Solution:** Added the `map_public_ip_on_launch` setting to ensure resources could connect to the internet.

## **Issue 2:**

### **Problem:** When building the pipeline, the WordPress image would push to ECR, but after installing WordPress and attempting to log in as admin, the page would just refresh.
### **Solution:** Avoided using any Dockerfile or docker-compose file. Instead, created the pipeline to pull, tag, and push the official WordPress Docker image directly to ECR.

## **Prerequisites**
### Before starting this project, ensure you meet the following prerequisites:

1. **AWS Account:** An active AWS account is required to create and manage the necessary cloud resources.
2. **Knowledge of AWS Services:** Familiarity with key AWS services such as VPC, ECR, ECS Fargate, EFS, and RDS is essential for understanding and configuring the infrastructure components.
3. **Terraform:** Basic understanding of Terraform and its syntax for writing infrastructure as code.
4. **GitHub and GitHub Actions:** Knowledge of GitHub for version control and GitHub Actions for setting up and managing CI/CD pipelines.
5. **Docker:** Understanding Docker, including how to pull, tag, and push Docker images, is crucial for handling the WordPress container.
6. **Command Line Interface (CLI):** Comfort with using the command line to execute Terraform commands, Docker commands, and other related tasks.
### These prerequisites ensure that you have the necessary skills and tools to successfully deploy and manage a WordPress website using DevOps principles on AWS.

## **Steps to Complete the Project**

### PS: If you get stuck with terraform configuration, you can find the one I used in the folder called `usefull-files`.

### **Step 1:**

### Create 2 GitHub repository, 1 to host `Terraform` configuration and 1 to deploy/push WordPress docker image `Docker`.

### **Step 2:** Create Terraform Configuration for S3 Bucket
- Create a Terraform configuration file `provider.tf` to create the region and an S3 bucket.
- Apply the configuration to create the bucket: `terraform init`, `terraform apply`

### **Step 3:** Map Backend to S3 Bucket

- Create `backend.tf` to use the S3 bucket for the Terraform backend.
- Delete the state-file files from your computer so on the next init, terraform will use S3 to host the state-file.

### **Step 4:** Create the Rest of AWS Infrastructure

### PS: To keep things simple, you can create different `.tf` files for every configuration you need.

### **Create:**
- `variables.tf`(keep all the variables needed) 
- `network.tf` (VPC, Subnets, Internet Gateway, Route tables and route association, Security groups)
- `database.tf` (Database and db_subnet_groups)
- `main.tf` (Load balancer, LB target group, LB listener, ECR, ECS task definition, ECS cluster, ECS service)
- `efs.tf` (EFS file system, EFS mount target, EFS access point)

### **Step 5:**

### **Create the CI/CD pipeline in GitHub**

- Create a GitHub Actions workflow file (.github/workflows/deploy.yml) to automate the CI/CD process. (If you need an example, you can find it in Docker folder)

### **Step 6:**

### **Initialize and apply the configuration:**

- terraform init
- terraform apply

### **Step 7:**

### **Run the pipeline**
- Run the pipeline as soon as `ECR` is created using `Terraform`, this way, the task definition will register and run a task based on the image from ECR.


## Here is the main page:
![main-page](/Project-8-WP-Deployed-On-ECS/images/main-website.png)

## Here is the admin page to customize the wrbsite:
![admin-page](/Project-8-WP-Deployed-On-ECS/images/admin-website.png)

## **Conclusion**

### By harnessing the power of Terraform for infrastructure automation and GitHub Actions for continuous integration and deployment, this project showcases an efficient and effective way to deploy a WordPress website on AWS. The automated pipeline ensures that a robust, scalable, and secure WordPress environment can be up and running in less than 5 minutes. This approach not only simplifies the deployment process but also aligns with best practices in DevOps, providing a seamless and reliable solution for managing WordPress deployments in the cloud.
