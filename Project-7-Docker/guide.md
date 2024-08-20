# Deploy a Website using Docker

### In this project I will deploy a website on the localhost using a docker image from my docker repo, then I will modify the image and redeploy the website. 
### Once I have the new image, I will create an AWS ECR (Elastic Container Registry), I will push the image to the ECR and deploy it using Fargate for wordwide access.

## Part 1: Deploy the super website:

### 1. I opened command prompt and ran `WSL` (I'm on a windows machine, if you have Linux or MacOS you don't have to do this) so I can run any Linux commands in the terminal.
### TIP: I recommend to use `export PROMPT_DIRTRIM=1` to make a shorter path so it will go from `/mnt/c/Users/paul_/OneDrive/Desktop/docker-test` to `/docker-test`

![start](pics/start.png)

### 2. With the following commands I will check if I have any docker images or docker containers:

`docker images` `docker ps -a`

![empty-img-container](pics/empty-image-container.png)

### 3. Using the command `docker search <image>` I am looking for my image in Docker Hub.

![search-image](pics/search.png)

### 4. I use `docker pull paulciurean/paul_tech:1.0` to pull the image from Docker Hub on my local machine.

![pull-request](pics/pull-image.png)

### 5. I check to see if I've got the image with `docker images` and run a container using that image. To do that I use `docker run -d --name paul_website -p 80:80 paulciurean/paul_tech:1.0`

![run-container](pics/run-container.png)

### 6. Open a new browser and run `localhost:80` to see the Super Website.
### Note: If you want to create another container, you need to give it a different port range(e.g: 81:80) because you can not have 2 containers running on the same port.

![super-website](pics/super-website.png)

### You can stop here and play around with the above commands, try to create different websites or you can follow the guide til the end. 

## Part 2: Modify the existing website:

### 1. Connect to the container using `docker exec -it <name> /bin/bash`. I'll check what files we have here and what I want to change.
### Note: You can use either Container ID or the name of the container here. In the image below you will see me using the Container ID

![connect-to-container](pics/connect-to-container.png)

### 2. Exit the container with `exit` command, and copy the new picture for the new website. We do this by using `docker cp <new picture> <website-name>:/app/`
### I connect back to the container and check if I have the new picture where it has to be.

![copy-new-img-to-container](pics/new-img.png)

### 3. I ran into a problem, when trying to open `index.html` I can't because I don't have `VIM` installed on this container. To install it run `apt-get install vim`

![vim-error](pics/vim-error.png)

### 4. I open the file `index.html` to modify the website.

![index-file](pics/index-file.png)

### 5. I then create the image by using `docker commit <your-website> <your-repo:new-tag>` 
### You can check if you created the new docker images correctly.

![commit-img](pics/commit-img.png)

### 6. In case your image doesn't have a name, you can use `docker tag` to change the name and tag for it, and with `docker push <new-image>` you can push it to the Docker Hub repo. 

![docker-push](pics/docker-push.png)

### 7. Time to launch the new website :D 
`docker run -d --name learning_website -p 81:80 paulciurean/paul_tech:1.2`

![launch-new-website](pics/launch-new-website.png)

### 8. Open a new browser and run `localhost:81` to see the new website.

![new-website](pics/new-website.png)

### 9. You can check that you have 2 different websites on 2 containers.

![2-websites](pics/2-websites.png)

## Part 3: Now let's deploy it in AWS:

### 1. First we create a repo in ECR:
### PS: Ignore the `Unknown output type: JSON`, if you want to make sure the command did work, you can log into your AWS account and check ECR repos.
### PSS: Make sure you use your own `account-id`, `alb-arn`, `target-group-arn` and any other variables which are unique.

`aws ecr create-repository --repository-name paul_tech --region us-east-1`

![create-ecr](pics/create-ecr-in-aws.png)

### 2. Authenticate Docker to the Amazon ECR registry:

`aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com`

![login-aws](pics/login-aws.png)

### 3. I will have to tag my docker image: 

`docker tag paulciurean/paul_tech:1.2 <account-id>.dkr.ecr.us-east-1.amazonaws.com/paul_tech:1.2`

### 4. Push the docker image to ECR repo:

`docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/paul_tech:1.2`

![push-img-ecr](pics/push-img-in-ecr.png)

### 5. Create the ECS cluster: 

`aws ecs create-cluster --cluster-name my-cluster --region us-east-1`

![create-ecs-cluster](pics/create-ecs-cluster.png)

### 6. Create a task definition:

`vim task-definition.json`

```
{
  "family": "my-task",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "my-container",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/paul_tech:1.2",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole"
}

```

![create-task-def](pics/create-task-def.png)

### 7. Register the task definition:

`aws ecs register-task-definition --cli-input-json file://task-definition.json --region us-east-1`

### 8. Create a target group for Aplication Load Balancer:

`aws elbv2 create-target-group --name my-target-group --protocol HTTP --port 80 --vpc-id <your-vpc> --target-type ip --region us-east-1`

### 9. Create the Aplication Load Balancer:

`aws elbv2 create-load-balancer --name my-alb --subnets <subnet-1> <subnet-2> --security-groups <security-groups> --region us-east-1`

### 10. Create the ALB listener:

`aws elbv2 create-listener --load-balancer-arn <alb-arn> --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=<target-group-arn> --region us-east-1 `

### 11. Create an ECS Service with the Load Balancer:

```
aws ecs create-service --cluster my-cluster --service-name my-service --task-definition my-task --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[<subnet-1>,<subnet-2>],securityGroups=[sg-089ba5e2081a09926],assignPublicIp=ENABLED}" --load-balancers '[{"targetGroupArn":"<target-group-id>","containerName":"my-container","containerPort":80}]' --region us-east-1
```

![create-service](pics/create-service.png)

### You can stop here if you don't have a domain name. You can get the ALB DNS name and run it in a new browser, it will display the new website ran on ECS, which is accessible by everyone on internet.

### PS: You might have to wait few minutes for the ECS service to be created.

## Part 4: Attach a Domain Name to ALB:

### 1. I will create a Route53 hosted zone:

![change-batch](pics/change-batch.png)

```
{
  "Comment": "Creating Alias resource record sets in Route 53",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "<your-domain-name>",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",  // Hosted zone ID for ALB in us-east-1
          "DNSName": "<your-alb>",
          "EvaluateTargetHealth": false
        }
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "www.<your-domain-name>",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",  // Hosted zone ID for ALB in us-east-1
          "DNSName": "<your-alb>",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}

```

### PS: Don't change the HostedZoneID because that's the one for `us-east-1`, if you want to create a hosted zone in another region, make sure to check the AWS docs for the HostedZoneID

### 2. Update the Route53 record:
`aws route53 change-resource-record-sets --hosted-zone-id <your-hosted-zone> --change-batch file://change-batch.json`

![create-records](pics/create-records.png)

## Now you can access your domain name (e.g.: digitalcloudadvisor.info) and you have full access to your website.

![final-website](pics/final-website.png)


## You've reached the end of tutorial, if you want to discuss with me about this project, message me on [LinkedIn](https://www.linkedin.com/in/ciprian-paul-ciurean-80386424b/)

## Hope you enjoyed it.

# THE END