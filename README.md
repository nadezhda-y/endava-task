
## Nadezhda Yovkova

[![N|Solid](https://i0.1616.ro/media/2/2621/33206/16842292/3/endava-logo-1000x520.jpg?width=514)]()



Requirements
1. Create public git repository
2. Choose a free Cloud Service Provider and register a free account with AWS, Azure, etc.
3. Automate provision of an Application stack running load balancer, web server and database of your choice, with the tools you like to use - Bash, Puppet, Chef, Ansible, Terraform, etc. Important - each of the services must run separately - on a virtual machine, container or as a service.
4. Include service monitoring in the automation
5. Automate service-fail-over, e.g. auto-restart of failing service
6. Document the steps in git history and commit your Infrastructure-as-a-code in the git repo
7. Send us link for the repository containing the finished solution
8. Present a working solution, e.g. not a powerpoint presentation, but a working demo
## Architecture 

- The infrastructure is fully automated.
- We use AWS account to create an instance with Ubintu. The setup will be executed with Terraform.
- With Ansible we will create docker compose services - 2 php containers and 1 mysql database. We will achieve the load balancing when we add them in docker swarm network. If one of the container failed, it will restart automatically. 
- The php site will connect to the database. 
- We will use Nagios to monitoring the docker containers. 

## Prerequisite 

- Own AWS account
- Ansible
- Terraform
- SSH keys ( public & private)


## Installation

1. Edit the terraform.tf

```
provider "aws" {
access_key="<your_access_key>"
secret_key="<<your_secret_key>>
region="us-east-1"
}
```

2. Edit your ansible.cfg to find the roles or just make ln link in playbooks will be enough.  

```
roles_path = ../roles/
```
3. Run the terraform plan. pvt_key and pub_key should point to your SSH keys directory. 

```
terraform plan
terraform apply -var "pvt_key=~/.ssh/id_rsa" -var "pub_key=~/.ssh/id_rsa.pub" -auto-approve
```

4. Get the ip from inventory file.
```
# cat ansible/inventory 
docker ansible_host=<AWS IP>
```
5. Open in your browser <AWS IP>:8080 and you will open the php site with query to database for the most big city in Bulgaria. 

6.Open in your browser <AWS IP>/nagios3 and you can see the Nagios server. To log in use the user and pass:
```
user: nagiosadmin
pass: Password1
```
7.To destroy the environment.
```
terraform destroy -var "pvt_key=~/.ssh/id_rsa" -var "pub_key=~/.ssh/id_rsa.pub" -auto-approve
```
