accessing
connect: aLogin
	connection := self connectionClass new.
	connection 
		host: aLogin host;
		port: aLogin port asInteger;
		database: aLogin databaseName;
		user: aLogin username;
		password: aLogin password.
	connection connect