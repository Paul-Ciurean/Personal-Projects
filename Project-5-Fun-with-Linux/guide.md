# **Skills:** 

### Below skills are required to complete the deployment steps:
### Linux User Management, Permissions, Directory Structure, File Systems, File Management

# **Pre-Requisites:**

### Login to AWS cloud and create Linux based EC2 instance to complete the below assignment.

# **Deployment**

## Step 1: Login to the server as super user and perform below:
1. Create users and set passwords – user1, user2, user3

```
sudo passwd root
su -
adduser user1
adduser user2
adduser user3

passwd user1
passwd user2
passwd user3

cat /etc/passwd
```

![user-creation](/Project-5-Fun-with-Linux/pics/user-list.png)

2. Create Groups – devops, aws

```
groupadd devops
groupadd aws
cat /etc/group
```
![group-list](/Project-5-Fun-with-Linux/pics/groups-list.png)


3. Change primary group of user2, user3 to ‘devops’ group

```
id user2
id user3
usermod -g devops user2
usermod -g devops user3
id user2
id user3
```

![users-id](/Project-5-Fun-with-Linux/pics/users-id.png)

4. Add ‘aws’ group as secondary group to the ‘user1’

```
usermod -aG aws user1
id user1
```
![group-add](/Project-5-Fun-with-Linux/pics/user-add-group.png)

5. Create the file and directory structure shown in the above diagram. For this, I suggest installing `tree` on your instance so you can see the structure of all dirs and files.

```
sudo yum install tree

mkdir -p home dir1 dir2/dir1/dir2/dir10 dir3/dir11 dir4/dir12 dir5/dir13 dir6 dir7/dir10 dir8/dir9 opt/dir14/dir10

touch dir1/f1 dir2/dir1/dir2/f3 dir4/dir12/f5 dir4/dir12/f4 dir7/f3 f1 f2 opt/dir14/f3

tree
```
![dir-structure](/Project-5-Fun-with-Linux/pics/dir-structure.png)


6. Change group of /dir1, /dir7/dir10, /f2 to “devops” group.  (Use `ll` to see the ownership of the dir/file)

```
ll
```

![dir-owners](/Project-5-Fun-with-Linux/pics/dir-groups.png)

```
chgrp devops dir1
chgrp devops dir7/dir10
chgrp devops f2

ll
```

![new-dir-owner](/Project-5-Fun-with-Linux/pics/new-dir-groups.png)

7. Change ownership of /dir1, /dir7/dir10, /f2 to “user1” user.

```
chown devops dir1
chown devops dir7/dir10
chown devops f2

ll
```

![new-dir-own](/Project-5-Fun-with-Linux/pics/new-dir-own.png)

## Step 2: Login as user1 and perform below:

### But before, as root, we need to give some permissions to user1.

```
sudo visudo
%user1 ALL=(ALL:ALL) ALL

su - user1 
```

1. Create users and set passwords – user4, user5

```
sudo adduser user4
sudo adduser user5
sudo passwd user4
sudo passwd user5
cat /etc/passwd
```
![new-users](/Project-5-Fun-with-Linux/pics/new-users.png)

2. Create Groups – app, database

```
sudo groupadd app
sudo groupadd database
cat /etc/group
```
![new-groups](/Project-5-Fun-with-Linux/pics/new-groups.png)


## Step 3:  Login as ‘user4’ and perform below: 

### Before that, we need to give permissions to user4 to work with the files and dirs.
```
sudo visudo
%user4 ALL=(ALL:ALL) /bin/cp, /bin/mv, /bin/mkdir, /usr/bin/touch
su - user4
```
1. Create directory – /dir6/dir4

```
sudo mkdir -p /root/dir6/dir4
```

2. Create file – /f3

```
sudo touch /root/f3
```

3. Move the file from “/dir1/f1” to “/dir2/dir1/dir2”

```
sudo mv /root/dir1/f1 /root/dir2/dir1/dir2
```

4. Rename the file ‘/f2′ to /f4’

```
sudo mv /root/f2 /root/f4
```

![user4-tasks](/Project-5-Fun-with-Linux/pics/user4-tasks.png)

## Step 4: Login as ‘user1’ and perform below: 


```
su - user1
```

1. Create directory – “/home/user2/dir1”

```
sudo mkdir -p /home/user2/dir1
```

2. Change to “/dir2/dir1/dir2/dir10” directory and create file “/opt/dir14/dir10/f1” using relative path method.

```
sudo cd /root/dir2/dir1/dir2/dir10
sudo mkdir -p /root/opt/dir14/dir10/f1
```

3. Move the file from “/opt/dir14/dir10/f1” to  user1 home directory

```
sudo mv /root/opt/dir14/dir10/f1 /home/user1
```

4. Delete the directory recursively “/dir4”

```
sudo rm -r /root/dir4
```

5. Delete all child files and directories under “/opt/dir14” using single command.

```
sudo find /root/opt/dir14 -mindepth 1 -delete
```

6. Write this text “Linux assessment for an DevOps Engineer!! Learn with Fun!!” to the /f3 file and save it.

```
sudo vi /root/f3
```

![user1-tasks](/Project-5-Fun-with-Linux/pics/user1-tasks.png)

## Step 5: Login as ‘user2’ and perform below: 

### Before we login as user2, we need to give him permissions as root.


```
sudo visudo
user2 ALL=(ALL:ALL) ALL
su - user2
```

1. Create file “/dir1/f2”

```
sudo touch /root/dir1/f2
```

2. Delete /dir6

```
sudo rm -r /root/dir6
```

3. Delete /dir8

```
sudo rm -r /root/dir8
```

4. Replace the “DevOps” text to “devops” in the /f3 file without using  editor.

```
sudo find /root/f3 -type f -exec sed -i 's/DevOps/devops/g' {} +
```

5. Using Vi-Editor copy the line1 and paste 10 times in the file /f3.

```
sudo vi /root/f3
```

6. Search for the pattern “Engineer” and replace with “engineer” in the file /f3 using single command.

```
:%s/Engineer/engineer/g
```

7. Delete /f3

```
sudo rm /root/f3
```

![user2-tasks](/Project-5-Fun-with-Linux/pics/user2-tasks.png)

## Step 6: Login as ‘root’ user and perform below: 

1. Search for the file name ‘f3’ in the server and list all absolute  paths where f3 file is found.

```
find / -type f -name "f3" 2>/dev/null
```

2. Show the count of the number of files in the directory ‘/’

```
ls -l / | wc -l
```

3. Print last line of the file ‘/etc/passwd’

```
tail -n 1 /etc/passwd
```

## Step 7: Login to AWS and create 5GB EBS volume in the same AZ of the EC2 instance and attach EBS volume to the Instance.

## Step 8: Login as ‘root’user and perform below: 

1. Create File System on the new EBS volume attached in the previous step.

```
lsblk
sudo mkfs -t ext4 /dev/xvdf
sudo mkdir /mnt/data
```

2. Mount the File System on /data directory.

```
sudo mount /dev/xvdf /mnt/data
```

3. Verify File System utilization using ‘df -h’ command – This command must show /data file system.

```
df -h'
```

4. Create file ‘f1’ in the /data file system.

```
touch /mnt/data/f1
```

![mount-ebs](/Project-5-Fun-with-Linux/pics/mount-ebs.png)

## Step 9: Login as ‘user5’ and perform below: 

### PS: Don't forget to give user5 some permissions.

1. Delete /dir1

```
sudo rm -r /root/dir1
```

2. Delete /dir2

```
sudo rm -r /root/dir2
```

3. Delete /dir3

```
sudo rm -r /root/dir3
```

4. Delete /dir5

```
sudo rm -r /root/dir5
```

5. Delete /dir7

```
sudo rm -r /root/dir7
```

6. Delete /f1 & /f4

```
sudo rm -r /root/f1 /root/f4
```

7. Delete /opt/dir14

```
sudo rm -r /root/opt/dir14
```

![skinny-tree](/Project-5-Fun-with-Linux/pics/skinny-tree.png)

## Step 10: Logins as ‘root’ user and perform below: 

1. Delete users – ‘user1, user2, user3, user4, user5’.

```
sudo userdel -f user1
sudo userdel -f user2
sudo userdel -f user3
sudo userdel -f user4
sudo userdel -f user5

cat /etc/passwd
```
![no-users](/Project-5-Fun-with-Linux/pics/no-users.png)

2. Delete groups – app, aws, database, devops. 

```
sudo groupdel app
sudo groupdel aws
sudo groupdel database
sudo groupdel devops

cat /etc/group
```

3. Delete home directories  of all users ‘user1, user2, user3, user4, user5’ if any exists still.

```
sudo rm -r home
```

4. Unmount /data file system.

```
sudo umount /mnt/data
```

5. Delete /data directory

```
sudo rm -r /mnt/data
```

![unmount-ebs](/Project-5-Fun-with-Linux/pics/unmount-ebs.png)

## Step 11: Login to AWS and detach EBS volume to the EC2 Instance and delete the volume and then terminate EC2 instance.

## You've reached the end of the project. If you seek any assistance with the project don't hesitate to contact me. 

## If you encounter any errors during the project, Google might be your best friend :D 

# THE END!!! 
