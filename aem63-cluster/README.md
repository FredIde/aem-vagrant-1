AEM 63 Cluster Configuration (all-in-one-server)
==============================
Note : The result is one Ubuntu Server with Mongo 3.2.11 ( Primary-Secondary-Secondary replica set  with Two AEM Nodes)

One time manual Steps 
- Place AEM Installable and licence
- Configure Mongo Replicaset
- Create AEM Author DB and User
- Start AEM on Each Node

Place AEM Installable and licence
---------------------------------
- Copy AEM 63 Installable and licence.properties to aem-vagrant/share/aem-software
- Installable name should be "cq-quickstart-6.3.0.jar" , If you are using a different name then the provisioning script has to be tweaked.

Configure Mongo Replicaset
---------------------------

- Start Mongo on each node
        
        $ vagrant ssh
        or
        $ ssh vagrant@192.168.63.100
        (password for 'vagrant' is 'vagrant')
		
        $ sudo su - mongod

		$ mongod -f /apps/mongodb/node1/conf/mongod.conf
        $ mongod -f /apps/mongodb/node2/conf/mongod.conf
        $ mongod -f /apps/mongodb/node3/conf/mongod.conf
        
	
    Mongo demons will be started on 27017,27018,27019
    
  Note : To Stop Mongo use 
         $ mongod -f /apps/mongodb/node1/conf/mongod.conf --shutdown
         $ mongod -f /apps/mongodb/node2/conf/mongod.conf --shutdown
         $ mongod -f /apps/mongodb/node3/conf/mongod.conf --shutdown
         
- Connect to Mongo Shell on 27017


		$ mongo

- Initiate Replcaset (Add the ips of other two nodes)


  	rs.initiate()
  	rs.conf()
  	rs.add("192.168.63.100:27018")
  	rs.add("192.168.23.102:27019")
  
  
- Configure authentication Shema

        use admin
        db.system.users.remove({})
        db.system.version.remove({})
        db.system.version.insert({ "_id" : "authSchema", "currentVersion" : 3 })
        
Create AEM Author DB and User
 ------------------------------
In mongo shell , execute the following snippet

		use aem63-author;
		  db.createUser( {
			  user: "aem63user",
			  pwd: "aemuser",
			  roles: [ { role: "readWrite", db: "aem-author" },
					   { role: "clusterMonitor", db: "admin" }
					 ]
		  }) ;


Starting AEM on Each Node 
-------------

AEM Node1 - 4502 
AEM Node2 - 5502

- sudo su -
- AEM process should run with 'root' user permissions as the shareDS on host
- cd /apps/aem/author/node1/crx-quickstart/bin
- Starting AEM
		$ ./start
- Stoping AEM
		$ ./stop

