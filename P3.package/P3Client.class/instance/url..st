initialize-release
url: stringOrUrl
	"Set my connection settings from stringOrUrl according to the format
	psql://username:password@localhost:5432/databasename 
	with the minimum being psql://user@localhost"
	
	| url |
	url := stringOrUrl asUrl.
	self assert: url scheme = #psql.
	self
		host: url host;
		port: (url portIfAbsent: [ 5432 ]);
		user: url username;
		password: url password;
		database: url firstPathSegment 