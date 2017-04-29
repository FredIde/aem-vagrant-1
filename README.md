# AEM Virtual Boxes with Vagrant

[Adobe Experience Manager(AEM)](http://www.adobe.com/marketing-cloud/enterprise-content-management/web-cms.html) plays very critical part of [Adobe Digital Marketing Cloud](http://www.adobe.com/marketing-cloud.html) suite.

[Vagrant](https://www.vagrantup.com) is a powerful automation tool to build virtual machines based on VirtualBox,VMware as Providers with several provisioning options to install and configure the application in guest machine.


The VagrantFiles available in this project builds [VirtualBox](https://www.virtualbox.org/wiki/Downloads) based virtual machines.

[Shell provisioning](https://www.vagrantup.com/docs/provisioning/shell.html) is used to install AEM

The primary goal of this project is to build an AEM (specified version) instance in a VirtualBox , under 5 mins. Also tearing down the instances to freeup the resources under 2 mins.

Pre-Requisites
---
* Instal Vagrant
+ Install Virtual Box
+ Clone / Down load this git repo

NOTE : Please modify the Share path in VagrantFile , before executing (vagrant up)

High Level Steps
---
#### Build Ubuntu 64 bit Server (VagrantFile)
Look at VagrantFile (aem63-tarmk/VagrantFile)
```
Vagrant.configure("2") do |config|
  # Ubuntu 64 bit
  config.vm.box = "ubuntu/trusty64"
  # Check whether an updated version of ubuntu Virtual Box available
  config.vm.box_check_update = true
  # Mount a shared folder from host machine into guest .
  # Please change ../share to a location on your host
  # /share is mount available with in virtual machine
  config.vm.synced_folder "../share", "/share"
  # Section to specify server specs (cpus,memory,name,etc)
  config.vm.define "aem63-ubuntu" do |server|
    server.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--cpus", "2"]
        vb.name = "aem63-ubuntu"
        vb.memory = 4096
    end
    # Specify hostname and ip to locate it on local network
    server.vm.hostname = "aem63-ubuntu"
    server.vm.network :private_network, ip: "192.168.63.101"
    # Shell provisioning is being used 
    # provision-aem contains instruction to install AEM
    server.vm.provision :shell, path: "provision-aem", args: ENV['ARGS']
  end
end
```

#### Provision AEM (provision-aem)

Please take a look at provision-aem contents , but the steps are 

* Network Configurations of Virtual Machine
+ Preparing host for AEM Install
  * Create an user called 'aem' with ssh & sudo access
  * Create a folder /apps/aem/author , treated as AEM Install Root
+ Install Java 1.8
  * Download , Install and Configure Java 1.8
+ Install AEM
  * Copy AEM Installable JAR from share into /apps/aem/author
  * Unpack AEM Jar File
  * Copy Strtup Script from share/aem-configs
  * AEM 6.3 - Don't Copy FileDatastore Configurations
  
### Manual Steps
``` shell
SSH into Host (vagrant ssh) from the location where VagrantFile available
$ vagrant ssh
# Inside ubuntu machine execute
$ sudo su - ( to get root access into guest)
$ su - aem
$ cd /apps/aem/author/crx-quickstart
# Start AEM for the first time
$ bin/start
# Tail error.log 
$ tail -f logs/error.log

```

Access http://192.168.63.101:4502/ from host machine to verify the status of AEM

##### Alternative way to start AEM

As 'root' user within ubuntu server execute

```
$ /usr/local/bin/aem-init
```
The above script takes care of switching to aem user before starting AEM Server. 