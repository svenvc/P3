accessing
url
	^ ZnUrl new
		scheme: #psql;
		host: self host;
		port: self port;
		username: self user;
		password: self password;
		addPathSegments: (self database ifNotNil: [ { self database } ] ifNil: [ #() ]);
		yourself