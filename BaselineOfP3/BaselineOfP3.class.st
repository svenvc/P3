"
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

"
Class {
	#name : #BaselineOfP3,
	#superclass : #BaselineOf,
	#category : 'BaselineOfP3'
}

{ #category : #baseline }
BaselineOfP3 >> baselineOf: spec [
	<baseline>
	spec
		for: #common
		do: [
			spec baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ].
			spec baseline: 'ZTimestamp' with: [ spec repository: 'github://svenvc/ztimestamp:master/repository' ].
			spec baseline: 'Glorp' with: [ spec repository: 'github://pharo-rdbms/glorp:master/']
			spec package: 'P3' with: [ spec requires: #('NeoJSON' 'ZTimestamp') ].
			spec package: 'P3-Glorp' with: [ spec requires: #('P3' 'Glorp') ].
			spec group: 'default' with: #('P3').
			spec group: 'glorp' with: #('P3-Glorp') ]
]
