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

		use aem-author;
		  db.createUser( {
			  user: "aemuser",
			  pwd: "aemuser",
			  roles: [ { role: "readWrite", db: "aem-author" },
					   { role: "clusterMonitor", db: "admin" }
					 ]
		  }) ;