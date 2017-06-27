accessing
url: stringOrUrl
	| url |
	url := stringOrUrl asUrl.
	self assert: url scheme = #psql.
	self
		host: url host;
		port: (url portIfAbsent: [ 5432 ]);
		user: url username;
		password: url password;
		database: url firstPathSegment 