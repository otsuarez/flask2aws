flask2aws
=========

Deploying a flask app to an amazon EC2 instance using chef. 
A Vagrantfile for local testing is provided.

# Cookbooks

A couple of cookbooks from Opscode repository were used, as well a couple more for fullfilling dependencies. Three more were written to take care of deployment and configuration of the app's code and related services.

## Opscode cookbooks (github.com/cookbooks/)

* nginx
* database
* mysql (database cookbook dependency)
* openssl (mysql cookbook dependency)

## Custom cookbooks

* appstack (takes care of code deployment, from the code repository to the proper directory on the filesystem)
* webstack (handles all the configurations required for the app to work to be done across the whole app stack)
* uwsgi (webstack cookbook dependency)

The uwsgi cookbook only installs the uwsgi package. Since this package could be used by other cookbooks, it was created as an standalone cookbook.

# Conventions

## initial sql import

Upon deployment, the webstack creates a database, importing the file "db/initial.sql" from the app code directory.

## configuration files

### application database 

The webstack cookbook creates the config.py file, which defines the database connection string for the app on the app code directory.

### nginx site

It creates the nginx virtual host file with the configuration for using the uwsgi service as the backend. 

### uwsgi application

It creates the corresponding uwsgi aplication file for the uwsgi service daemon to serve the app code.

# Chef workstation

The whole setup requires 3 set of authentication credentials.

* github epo access
* chef server
* amazon aws

## github 

The application code is stored on a github repository. A new (not any personal one) ssh key pair was created. The public key was added as a deploy key to the repo on github. The private key was added to the application deployment cookbook (appstack).

## chef server

Using the chef server requires a client pem certificate which can be obtained via the Web console, creating a new client. That will allows you to work with the chef server from a workstation, using the knife command. For bootstrapping nodes, another credential is required, the validation.pem certificate. This one can be found on the /etc/chef/ directory of the chef server host filesystem.

## amazon

There're two levels of access here. One is related to the ssh key used to log into the servers created on amazon. This key will be stored usually on the ~/.ssh directory of the workstation. 

Create your SSH key pair for EC2 (at https://console.aws.amazon.com/ec2/home?#) and save your identity file on the local workstation (will be asumming you named the downloaded file acmeec2.pem)

```sh
cd ~/.ssh
mv ~/Downloads/acmeec2.pem .
chmod 400 acmeec2.pem
ssh-add ~/.ssh/acmeec2.pem
```

The other set of credentials are the ones used by the knife command for interacting with the AWS infrastructure. They are being used in the .chef/knife.rb file as env vars.
You need to add them to your ~/.bashrc or ~/.zshrc file.

```sh 
# EC2
export acme_aws_access_key_id="AKIAIGAI7VRAOZSBNAWA"
export acme_aws_secret_access_key="AfJVqDRQm145Gmz+eea9zkqvINIuHs/wjszaqdsN"
```

## Working with the knife command

creating the server

```sh
knife ec2 server create "role[webstack]" -I ami-3962a950  -x ubuntu --region eu-west-1
```

Checking the new server had been created and successfully added to the chef server.

```sh
osvaldo@local:~/src/acme/flask2aws$ knife ec2 server list
Instance ID      Public IP        Private IP       Flavor           Image            SSH Key          Security Groups  State          
i-1f17aa79       174.129.141.119  10.28.139.100    m1.small         ami-3962a950     acmeec2    default          running        
osvaldo@local:~/src/acme/flask2aws$ knife node list
  ip-10-28-139-100.ec2.internal
  localhost
osvaldo@local:~/src/acme/flask2aws$ 
osvaldo@otoja-lm:~/src/acme/flask2aws$ knife node show ip-10-28-139-100.ec2.internal
Node Name:   ip-10-28-139-100.ec2.internal
Environment: _default
FQDN:        ip-10-28-139-100.ec2.internal
IP:          174.129.141.119
Run List:    role[webstack]
Roles:       webstack
Recipes:     webstack
Platform:    ubuntu 11.10
osvaldo@otoja-lm:~/src/acme/flask2aws$ 
```
et voila!

Testing ssh connection to the amazon server and sudo privileges.

```sh
osvaldo@local:~/src/acme/flask2aws$  ssh ubuntu@174.129.141.119 -i ~/.ssh/acmeec2.pem 
Welcome to Ubuntu 11.10 (GNU/Linux 3.0.0-13-virtual i686)

 * Documentation:  https://help.ubuntu.com/

  System information as of Fri May 11 20:36:35 UTC 2012

  System load:  0.0              Processes:           53
  Usage of /:   8.9% of 9.84GB   Users logged in:     0
  Memory usage: 10%              IP address for eth0: 10.28.139.100
  Swap usage:   0%

  Graph this data and manage this system at https://landscape.canonical.com/
New release '12.04 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Get cloud support with Ubuntu Advantage Cloud Guest
  http://www.ubuntu.com/business/services/cloud
ubuntu@ip-10-28-139-100:~$ sudo su -
root@ip-10-28-139-100:~# 
```
