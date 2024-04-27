# Ansible Project 1 - Write your first playbook

## Ansible Basics - Getting started

## What is Ansible?

### Ansible is a powerful open-source automation tool that can help you manage and configure your servers, applications, and infrastructure effortlessly. Whether you're a seasoned pro or a beginner in the world of DevOps, Ansible is here to simplify your life.


## Why use Ansible?

- Simplicity: Ansible uses plain English and YAML files for configuration, making it accessible to everyone.
- Agentless: You don't need to install agents on target servers. Ansible works over SSH or WinRM, which most systems support by default.
- Versatility: It can handle a wide range of tasks, from simple server configuration to complex application deployments.

## Introduction to Ansible

### Ansible components:

- Control Node: This is your Ansible machine, where you write your playbooks and manage everything from.
- Managed Nodes: These are the servers or devices you want to automate. Ansible communicates with them via SSH (Linux) or WinRM (Windows).
- Playbooks: Think of them as recipes. Playbooks define the tasks you want to perform on your managed nodes.
- Modules: These are Ansible's building blocks. Modules are used to execute tasks, such as installing software or creating files.

## 1.0: Setting up your environment

### PS: For this step you will need 2 servers, you can launch them in AWS.

![servers](/images/step1/ec2.png)

## 1.1: Run the following commands to install Ansible:

`sudo ap update`

`sudo apt-get install ansible`

### Once that's installed, you can check it by running:

`ansible --version`

![version](/images/step1/ansible-version.png)

## 1.2: Create an inventory file:

`vim inventory`

### In this file you will add the IP address from the targer server.

![webserver](/images/step1/webserver.png)

### Save and quit.

## 1.3: Passwordless authentication:

### We have to make sure we can access the target server without a password, so next up we are going to set that.

`ssh-keygen` - Use this on the Ansible server

### This will generate a key, you can hit Enter on all the steps.

![ansible-key](/images/step1/key-gen.png)

## 1.4: We need to copy the public key from Ansible server to the Target server. 

### To do that, copy the public key from Ansible using the command:

`cat /home/ubuntu/.ssh/id_rsa.pub`

### This will open the public file. 

![pub-key](/images/step1/pub-file.png)

### Go to the Target server and check what files you have inside by running:

`ls ~/.ssh/`

### You should have "authorized_keys", open the file using 

`vim ~/.ssh/authorized_keys`

### Paste the key from the Ansible public key here. It should look like this:

![pub-key-to-target-sv](/images/step1/target-sv-paste-key.png)

### You might find another key there, make sure you have some space between the 2 keys.

## 1.5: Test the connection:

### You can test the connection to your managed nodes using the following command: 

`ansible -m ping -i inventory all`

![connection-success](/images/step1/connection-success.png)

## 1.6: Writing your first playbook:

### Check if Nginx is installed on the target server:

` sudo systemctl status nginx`

![nginx-status](/images/step1/nginx-status1.png)

### Let's put Ansible to work. Create your first playbook using a text editor:

`vim my_first_playbook.yml`

```
---
- name: Install Nginx
  hosts: web
  become: yes  # Run tasks with sudo
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Start Nginx
      service:
        name: nginx
        state: started
```

### We use --- at the top of the file to specify that this will be a YAML file.

### In the playbook we have the following:

- Name: The name of what we want to do. (e.g: Install Nginx)
- Host: Where we want to install Nginx
- Become: This will run the commands as root
- Tasks: The tasks the server needs to do to install Nginx

![first-playbook](/images/step1/first-playbook.png)

### Save and quit.

## 1.7: Run the playbook using the following command:

` ansible-playbook -i inventory my_first_playbook.yml`

![first-playbook-output](/images/step1/first-playbook-output.png)

## WELL DONE!

### You created the first playbook in Ansible. Let's test the target server if it has the Nginx installed.

## 1.8: Check if Nginx is installed on Target server by running the following command on the Target server:

` sudo systemctl status nginx `

![nginx-status](/images/step1/nginx-status2.png)

# THE END!! :D