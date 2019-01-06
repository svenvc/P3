"
P3ClientTest holds unit tests for the P3 PSQL client.

Configure by setting my class side's connection URL.

  P3ClientTests url: 'psql://sven:secret@localhost:5432/database'.

The minimal being the following:

  P3ClientTests url: 'psql://sven@localhost'.

Benchmarks

  P3ClientTests new setupBenchmark1.
  P3ClientTests new runBenchmark1.
  P3ClientTests new runBenchmark1Bench.
  P3ClientTests new runAllTests.
"
Class {
	#name : #P3ClientTest,
	#superclass : #TestCase,
	#instVars : [
		'client'
	],
	#classVars : [
		'Url'
	],
	#category : #'P3-Tests'
}

{ #category : #accessing }
P3ClientTest class >> url [
	"Return the default connection URL to use for P3 clients in the unit tests.
	Note that the default here corresponds to the default on Travis CI's postgresql service,
	user postgres with a blank password on localhost.
	You should set an appropriate connection string yourself, see #url:"
	
	^ Url ifNil: [ Url := 'psql://postgres@localhost' ]
]

{ #category : #accessing }
P3ClientTest class >> url: stringOrUrl [
	"Set the connection URL to be used for P3 Clients in the unit tests.
	The general syntax is psql://sven:secret@localhost:5432/database
	The minimal form is psql://user@localhost (a user, blank password, localhost)"
	
	Url := stringOrUrl asUrl
]

{ #category : #benchmarking }
P3ClientTest >> benchmark1Size [
	^ 10000
]

{ #category : #benchmarking }
P3ClientTest >> runAllTests [
	"Runs all tests on the same connection/session"
	
	| testSelectors timeToRun |
	testSelectors := self class selectors select: [ :each | 'test*' match: each ].
	self setUp.
	timeToRun := [ testSelectors do: [ :each | self perform: each ] ] timeToRun.
	self tearDown.
	^ timeToRun 
]

{ #category : #benchmarking }
P3ClientTest >> runBenchmark1 [
	| result timeToRun |
	result := nil.
	self setUp.
	timeToRun := [ result := client query: 'SELECT * FROM benchmark1' ] timeToRun.
	self assert: result numberOfRecords equals: self benchmark1Size.
	self tearDown.
	^ timeToRun 
]

{ #category : #benchmarking }
P3ClientTest >> runBenchmark1Bench [
	| result timeToRun |
	result := nil.
	self setUp.
	timeToRun := [ result := client query: 'SELECT * FROM benchmark1' ] benchFor: 5 seconds.
	self assert: result numberOfRecords equals: self benchmark1Size.
	self tearDown.
	^ timeToRun 
]

{ #category : #running }
P3ClientTest >> setUp [
	super setUp.
	client := P3Client new.
	client url: self class url.
	client connect
]

{ #category : #benchmarking }
P3ClientTest >> setupBenchmark1 [
	| timeToRun |
	self setUp. 
	timeToRun := [
		client query: 'DROP TABLE IF EXISTS benchmark1'.
		client query: 'CREATE TABLE benchmark1 (n_int INTEGER, n_float FLOAT, hex TEXT, roman TEXT, words TEXT)'.
		1 to: self benchmark1Size do: [ :n |
			| sql |
			sql := 'INSERT INTO benchmark1 (n_int, n_float, hex, roman, words) VALUES ({1}, {2}, ''{3}'', ''{4}'', ''{5}'')' 
				format: { n. Float pi * n. n printStringHex. n printStringRoman.  n asWords }.
			client query: sql ] ] timeToRun.
	self tearDown.
	^ timeToRun  
]

{ #category : #versionInfo }
P3ClientTest >> supportsJsonB [

	| record version |
	
	record := (client query: 'SHOW server_version') firstRecord.
	version := ($. split: record first) collect: [ :part | part asNumber ].
	
	^ version first > 9 or: [ 
		version first = 9 and: [ version second > 4 ]		
	]
]

{ #category : #running }
P3ClientTest >> tearDown [
	client close.
	super tearDown
]

{ #category : #testing }
P3ClientTest >> testArrayTypes [
	| result |
	client execute: 'DROP TABLE IF EXISTS table_a'.
	client execute: 'CREATE TABLE table_a (id INTEGER, name TEXT, text_a TEXT[], int_a INTEGER[])'.
	client execute: 'INSERT INTO table_a (id, name, text_a, int_a) VALUES (1, ''foo'', ARRAY[''foo'',''bar''], ARRAY[1,2])'.
	client execute: 'INSERT INTO table_a (id, name, text_a, int_a) VALUES (2, ''null'', ''{"NULL",NULL}'', ''{0,NULL}'')'.
	client execute: 'INSERT INTO table_a (id, name, text_a, int_a) VALUES (3, ''zero'', ''{}'', ''{}'')'.
	client execute: 'INSERT INTO table_a (id, name, text_a, int_a) VALUES (4, ''escape'', ARRAY[''a"b'',''c\d''], ''{1,2}'')'.
	result := client query: 'SELECT id, name, text_a, int_a FROM table_a WHERE id = 1'.
	self assert: result firstRecord equals: #(1 'foo' #('foo' 'bar') #(1 2)).
	result := client query: 'SELECT id, name, text_a, int_a FROM table_a WHERE id = 2'.
	self assert: result firstRecord equals: #(2 'null' #('NULL' nil) #(0 nil)).
	result := client query: 'SELECT id, name, text_a, int_a FROM table_a WHERE id = 3'.
	self assert: result firstRecord equals: #(3 'zero' #() #()).
	result := client query: 'SELECT id, name, text_a, int_a FROM table_a WHERE id = 4'.
	self assert: result firstRecord equals: #(4 'escape' #('a"b' 'c\d') #(1 2)).
	client execute: 'DROP TABLE table_a'
]

{ #category : #testing }
P3ClientTest >> testBooleanConversion [
	| result |
	result := client query: 'SELECT b::boolean FROM (VALUES (true), (false), (NULL)) t(b)'.
	self assert: result data equals: #((true) (false) (nil))
]

{ #category : #testing }
P3ClientTest >> testByteArrayConversion [

	| result bytes |
	
	client execute: 'DROP TABLE IF EXISTS testBytea'.
	client execute: 'CREATE TABLE testBytea (id int, bytes bytea)'.
	
	bytes := #[ 0 1 2 3 4 254 255 ].	
	client execute: ('INSERT INTO testBytea (id, bytes) VALUES (100, ''{1}'')' format: { '\x', bytes hex }).

	"Read the bytes back as a hex string"
	result := client query: 'SELECT encode(bytes, ''hex'') FROM testBytea WHERE id = 100'.
	self assert: result firstRecord first asLowercase equals: bytes hex asLowercase.

	"Read the bytes back as binary data"	
	result := client query: 'SELECT bytes FROM testBytea WHERE id = 100'.
	self assert: result firstRecord first equals: bytes.

	client execute: 'DROP TABLE testBytea'
]

{ #category : #testing }
P3ClientTest >> testChronology [
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, timestamp_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP, date_created DATE DEFAULT CURRENT_DATE, time_created TIME DEFAULT CURRENT_TIME)'.
	client execute: 'INSERT INTO table1 (name) VALUES (''Chronology'')'.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	self assert: result firstRecord second equals: 'Chronology'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	client execute: ('INSERT INTO table1 (name, timestamp_created, date_created, time_created) VALUES (''{1}'', ''{2}'', ''{3}'', ''{4}'')'
		format: { 'Pharo'. DateAndTime now. Date today. Time now }).
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 2'.
	self assert: result firstRecord first equals: 2.
	self assert: result firstRecord second equals: 'Pharo'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testConnection [
	self assert: client isConnected.
	self assert: client isWorking.
]

{ #category : #testing }
P3ClientTest >> testEmptyString [
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	client execute: 'INSERT INTO table1 (id, string) VALUES (1, '''')'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: #(1 '').
	client execute: 'INSERT INTO table1 (id, string) VALUES (2, NULL)'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: #(2 nil).
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testEnum [

	| result ooid |

	result := client 
		execute: 'DROP TABLE IF EXISTS table1;';
		execute: 'DROP TYPE IF EXISTS mood';
		execute: 'CREATE TYPE mood AS ENUM (''sad'', ''ok'', ''happy'');';
		execute: 'CREATE TABLE table1 (name text, current_mood mood );';
		execute: 'INSERT INTO table1 VALUES (''Moe'', ''happy'');'.
		
	result := client query: 'SELECT oid FROM pg_type WHERE typname = ''mood'';'.
	ooid := result firstRecord first.
	
	client converter 
		mapOid: ooid 
		type: #mood
		to: [ :reader :length :description | (reader next: length) asString asSymbol ].
		
	result := client query: 'SELECT * FROM table1 WHERE current_mood = ''happy'';'.
		
	self assert: result firstRecord equals: #('Moe' #happy)	
	

]

{ #category : #testing }
P3ClientTest >> testError [
	self should: [ client query: 'SELECT * FROM abcdef' ] raise: P3Error
]

{ #category : #testing }
P3ClientTest >> testIntegerConversion [
	| result |
	result := client query: 'SELECT i::integer FROM (VALUES (-1), (1), (NULL), (1234567890)) t(i)'.
	self assert: result data equals: #((-1) (1) (nil) (1234567890))
]

{ #category : #testing }
P3ClientTest >> testJsonConversion [
	| data result |
	
	self supportsJsonB ifFalse: [ ^ self skip ].
	data := NeoJSONObject new 
		x: 1; 
		str: 'les élève Français'; 
		foo: 'tab' , Character tab asString; 
		bar: #(true nil -123); 
		yourself.
	result := client query: ('SELECT ''{1}''::json' format: { data printString }).
	self assert: result firstFieldOfFirstRecord equals: data.
	result := client query: ('SELECT ''{1}''::jsonb' format: { data printString }).
	self assert: result firstFieldOfFirstRecord equals: data
]

{ #category : #testing }
P3ClientTest >> testMultiStatement [
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	result := client query: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true); INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	self assert: result results equals: #('INSERT 0 1' 'INSERT 0 1').
	self deny: result hasDescriptions.
	self deny: result hasData.
	result := client query: 'SELECT * from table1'.
	self assert: result firstResult equals: 'SELECT 2'.
	self assert: result firstRowCount equals: 2.
	self assert: result data equals: #((1 'foo' true)(2 'bar' false)).
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testNonAsciiStrings [
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	client execute: 'INSERT INTO table1 (id, string) VALUES (1, ''Les élèves Français'')'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: #(1 'Les élèves Français').
	client execute: ('INSERT INTO table1 (id, string) VALUES (2, ''100 {1}'')' format: { Character euro }).
	result := client query: 'SELECT id, string FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: {2. '100 {1}' format: { Character euro }}.
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testNotification [
	| raised |
	raised := false.
	[ client query: 'SET client_min_messages TO notice; DROP TABLE IF EXISTS abcdef' ] 
		on: P3Notification 
		do: [ :notification | 
			raised := true.
			self 
				assert: (notification description includesSubstring: 'abcdef')
				description: ('{1} does not contain abcdef' format: {notification description}).
			notification resume ].
	self assert: raised description: 'no notification triggered'
]

{ #category : #testing }
P3ClientTest >> testQueryCatalog [
	| result |
	result := client query: 'SELECT schemaname,tablename FROM pg_catalog.pg_tables'.
	"there are two columns"
	self assert: result numberOfColumns equals: 2.
	"this was a select"
	self assert: ($ split: result firstResult) first equals: 'SELECT'.
	"the select returned a count for the number of dataRows"
	self assert: result rowCount equals: result numberOfRecords.
	"each dataRow has two fields"
	self assert: (result data allSatisfy: [ :each | each size = 2])
]

{ #category : #testing }
P3ClientTest >> testSession [

	| session |
	
	session := client session. "from #setUp"
	
	self assert: client session isNotNil.
	
	client execute: 'SELECT NOW();'.
	
	self assert: session equals: client session.
	
	client close.
	
	self assert: client session isNil.
	
	client connect.
	
	self deny: session = client session.
	
	client clearSession.
	
	self 
		deny: client isConnected;
		assert: client session isNil.
		
	
	
	
	



]

{ #category : #testing }
P3ClientTest >> testSimpleTable [
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (NULL, NULL, NULL)'.
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: #(1 'foo' true).
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: #(2 'bar' false).
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id IS NULL'.
	self assert: result firstRecord equals: #(nil nil nil).
	client execute: 'DELETE FROM table1 WHERE id IS NULL'.
	client execute: 'UPDATE table1 SET name = ''xxx'' WHERE id = 2'.
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: #(2 'xxx' false).
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testSqlFunction [
	| x y result |
	client execute: 'DROP FUNCTION IF EXISTS my_add(x INTEGER, y INTEGER)'.
	client execute: 'CREATE FUNCTION my_add(x INTEGER, y INTEGER) RETURNS INTEGER AS $$ SELECT x + y $$ LANGUAGE SQL'.
	x := 99 atRandom.
	y := 99 atRandom.
	result := client query: ('SELECT my_add({1},{2}) AS answer' format: { x. y }).
	self assert: result firstFieldOfFirstRecord equals: x + y.
	client execute: 'DROP FUNCTION my_add(x INTEGER, y INTEGER)'.
]

{ #category : #testing }
P3ClientTest >> testStringEscaping [
	| result string |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	string := 'An SQL string with a single quote '' and a double quote ".'.
	"We can use #printString as Pharo strings are similar to SQL string"
	client execute: ('INSERT INTO table1 (id, string) VALUES ({1}, {2})' format: { 1. string printString }).
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: { 1. string }.
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testTimeout [
	"Reconnect with an explicit timeout"
	client close.
	client url: Url.
	client timeout: 1. "second"
	self assert: client isWorking.
	"The following (sleeping for 0.5 seconds) should just pass successfully"
	client execute: 'SELECT pg_sleep(0.5)'.
	"While the following (sleeping for 1.5 seconds) should time out"
	self should: [ client execute: 'SELECT pg_sleep(1.5)' ] raise: ConnectionTimedOut 
]

{ #category : #testing }
P3ClientTest >> testTimezone [
	| result originalTimezone |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, t1 TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP, t2 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP)'.
	originalTimezone := client converter timezone id.
	client execute: ('INSERT INTO table1 (name) VALUES (''{1}'')' format: { originalTimezone }).
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	self assert: result firstRecord second equals: client converter timezone id.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (DateAndTime now - result firstRecord fourth) abs < 30 seconds.
	client execute: 'SET TIMEZONE TO ''GMT'''.
	result := client query: 'SHOW TIMEZONE'.
	self assert: result firstFieldOfFirstRecord equals: 'GMT'.
	client converter timezone: (ZTimezone gmt).
	client execute: ('INSERT INTO table1 (name) VALUES (''{1}'')' format: { client converter timezone id }).
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	"t1 is now off, since postgres did not adjust it"
	self assert: (DateAndTime now asUTC - result firstRecord fourth) abs < 30 seconds.
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 2'.
	self assert: result firstRecord first equals: 2.
	self assert: result firstRecord second equals: client converter timezone id.
	self assert: (DateAndTime now asUTC - result firstRecord third) abs < 30 seconds.
	self assert: (DateAndTime now asUTC - result firstRecord fourth) abs < 30 seconds.
	client execute: ('SET TIMEZONE TO ''{1}''' format: { originalTimezone }).
	client converter timezone: (ZTimezone id: originalTimezone).
	client execute: 'DROP TABLE table1'
]

{ #category : #testing }
P3ClientTest >> testUuid [

	| result uuid num |
	
	client execute: 'DROP TABLE IF EXISTS testUUID'.
	client execute: 'CREATE TABLE testUUID (id UUID, num INTEGER)'.
	
	uuid := UUID new.
	num := 1234 atRandom.
	
	client execute: ('INSERT INTO testUUID (id, num) VALUES (''{1}'', {2})' format: { uuid. num }).
	result := client query: ('SELECT * FROM testUUID WHERE id = ''{1}''' format: {uuid}).
	
	self assert: result firstRecord equals: { uuid. num }.
	
	client execute: 'DROP TABLE testUUID'
]
