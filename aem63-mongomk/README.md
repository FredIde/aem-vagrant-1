AEM 63 Cluster Configuration
==============================
- Configure Mongo Replicaset
- Create AEM Author DB and USer
- Configure Shared Data Store
- Start AEM on Each Node

Configure Mongo Replicaset
---------------------------

- Start Mongo on each node

		$ sudo su - mongod

		$ mongod -f /etc/mongod.conf
	
- Connect to Mongo Shell on "192.168.23.101"


		$ mongo

- Initiate Replcaset (Add the ips of other two nodes)


  	rs.initiate()
  	rs.conf()
  	rs.add("192.168.23.101:27017")
  	rs.add("192.168.23.102:27017")
  
  
- Configure authentication Shema

		use admin
		var schema = db.system.version.findOne({"_id" : "authSchema"})
		schema.currentVersion = 3
		db.system.version.save(schema);

Create AEM Author DB and User
 ------------------------------
In mongo shell , execute the following snippet

		use aem63-author;
		  db.createUser( {
			  user: "aem63user",
			  pwd: "aemuser",
			  roles: [ { role: "readWrite", db: "aem63-author" },
					   { role: "clusterMonitor", db: "admin" }
					 ]
		  }) ;

Configuring Shared Data Store
----------------------------
As there are multiple AEM nodes going to write / read from datastore , the datastor has to to be mounted on a shared mount

The following commnad takes care of the symlinking the datastore path to external shared path

	ln -s /share/aem63-mongo-fds $AEM_ROOT/crx-quickstart/repository/datastore
	

Starting AEM on Each Node
-------------

- ssh into AEM Server (ssh vagrant@replace.with.ip)
- sudo su -
- AEM process should run with 'root' user permissions as the shareDS on host
- cd /apps/aem/author/bin
- Issue command 
		$ ./start

