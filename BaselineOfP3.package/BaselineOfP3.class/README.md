I am BaselineOfP3, I am a BaselineOf used to load the P3 PostgreSQL client.

The default group loads P3Client and its basic dependencies NeoJSON and ZTimestamp

	Metacello new
		baseline: 'P3';
		repository: 'github://svenvc/P3';
		load.

You could then try (general URL psql://username:password@localhost:5432/databasename)

	(P3Client new url: 'psql://sven@localhost') in: [ :client |
		[ client isWorking  ] ensure: [ client close ] ].

The glorp group loads P3DatabaseDriver and the whole of Glorp (warning: large download)
 
	Metacello new
		baseline: 'P3';
		repository: 'github://svenvc/P3';
		load: 'glorp'.

Manually install the driver 

	PharoDatabaseAccessor DefaultDriver: P3DatabaseDriver.
	
Use a login that looks as follows

	Login new
		database: PostgreSQLPlatform new;
		username: 'username';
		password: 'password';
		connectString: 'host:5432_databasename';
		encodingStrategy: #utf8;
		yourself.
