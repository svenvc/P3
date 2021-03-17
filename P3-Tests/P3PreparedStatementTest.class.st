"
P3PreparedStatementTest holds unit tests for the P3PreparedStatement class.

I reuse the configuration of P3ClientTests. Example:

  P3ClientTest url: 'psql://sven:secret@localhost:5432/database'.
"
Class {
	#name : #P3PreparedStatementTest,
	#superclass : #TestCase,
	#instVars : [
		'client'
	],
	#category : #'P3-Tests'
}

{ #category : #running }
P3PreparedStatementTest >> setUp [
	super setUp.
	client := P3Client new.
	client url: P3ClientTest url.
	client timeout: 10. "second"
	client connect
]

{ #category : #running }
P3PreparedStatementTest >> tearDown [
	client close.
	super tearDown
]

{ #category : #tests }
P3PreparedStatementTest >> testBatchInsertStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	result := statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )
	).
	
	self assert: result size equals: 3.
	result do: [ :each |
		self assert: each equals: 'INSERT 0 1' ].
	
	statement close.
]

{ #category : #tests }
P3PreparedStatementTest >> testBinaryColumn [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, bytes BYTEA)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, bytes) VALUES ($1,$2)'.
	statement execute: #( 123 #[ 100 102 104 200 255 0 1 2 ] ).
	statement execute: #( 345 #[ 100 102 104 106 108 100 102 104 106 108 ]  ).
	statement close.
	
	statement := client prepare: 'SELECT bytes from table1 WHERE id = $1'.
	result := statement queryAll: #( ( 123 ) ( 345 ) ).
	statement close.

	self assert: #( #[ 100 102 104 200 255 0 1 2 ] ) equals: (result at: 1) firstRecord.
	self assert: #( #[ 100 102 104 106 108 100 102 104 106 108 ] ) equals: (result at: 2) firstRecord.
	
]

{ #category : #tests }
P3PreparedStatementTest >> testBitString [
	| statement bitString fixedBitString result |
	
	client execute: 'DROP TABLE IF EXISTS testBits'.
	client execute: 'CREATE TABLE testBits (id INT, b1 BIT, b2 BIT VARYING, b3 BIT(8), b4 BIT VARYING(8))'.
	
	bitString := P3BitString bits: 2r11001111.
	fixedBitString := P3FixedBitString bits: 2r11110011.
	
	statement := client prepare: 'INSERT INTO testBits (id, b1, b2, b3, b4) VALUES ($1, $2, $3, $4, $5)'.
	statement execute: { 100. P3FixedBitString one. bitString. fixedBitString. bitString }.
	
	statement := client prepare: 'SELECT b1, b2, b3, b4 FROM testBits WHERE id = $1'.
	result := statement query: #( 100 ).
	
	self assert: result firstRecord equals: { P3FixedBitString one. bitString. fixedBitString. bitString }.
	
	client execute: 'DROP TABLE testBits'
]

{ #category : #tests }
P3PreparedStatementTest >> testBulkInsertAndSelect [

	| insertStatement result selectStatement |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, created_at TIMESTAMP DEFAULT NOW(), name TEXT)'.
	
	insertStatement := client prepare: 'INSERT INTO table1 (name) VALUES ($1) RETURNING id, created_at'.
	result := insertStatement queryAll: ((1 to: 100) collect: [ :index | Array with: ('Text #', index printString) ]).
	
	self assert: result size equals: 100.
	result do: [ :each |
		self assert: each data size equals: 1.
		self assert: each firstRecord size equals: 2 ].
	
	selectStatement := client prepare: 'SELECT name FROM table1 WHERE id = $1 AND created_at = $2'.
	result := selectStatement queryAll: (result collect: [ :each | each firstRecord ]).
	
	self assert: result size equals: 100.
	result doWithIndex: [ :each :index |
		self assert: each data size equals: 1.
		self assert: each firstRecord equals: (Array with: 'Text #', index printString) ].

	insertStatement close.
	selectStatement close.
]

{ #category : #tests }
P3PreparedStatementTest >> testChronology [
	| result statement |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, timestamp_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP, date_created DATE DEFAULT CURRENT_DATE, time_created TIME DEFAULT CURRENT_TIME)'.
	statement := client prepare: 'INSERT INTO table1 (name) VALUES ($1)'.
	statement execute: { 'Chronology' }.
	statement close.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	self assert: result firstRecord second equals: 'Chronology'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	statement := client prepare: 'INSERT INTO table1 (name, timestamp_created, date_created, time_created) VALUES ($1, $2, $3, $4)'.
	statement execute: { 'Pharo'. DateAndTime now. Date today. Time now }.
	statement close.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 2'.
	self assert: result firstRecord first equals: 2.
	self assert: result firstRecord second equals: 'Pharo'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3PreparedStatementTest >> testGeometricTypes [
	| p1 p2 p3 points row1 row2 row3 statement result |
	(client isServerVersionAtLeastMajor: 9 minor: 4) ifFalse: [ ^ self skip ].
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL, p POINT, b BOX, c CIRCLE, l1 LINE, l2 LSEG, p1 POLYGON, p2 PATH)'.
	
	p1 := P3Point x: 1 y: 2.
	p2 := P3Point x: 3 y: 4.
	p3 := P3Point x: 5 y: 6.
	points := { p1. p2. p3}.
	row1 := { P3Point unit. P3Circle unit. P3Box unit. P3Line xAxis. P3LineSegment xAxisUnit.
		P3Polygon points: points. P3Path points: points }. 
	row2 := { P3Point zero. P3Circle unit. P3Box unit. P3Line yAxis. P3LineSegment yAxisUnit.
		P3Polygon points: points reversed. P3Path openPoints: points reversed }.
	row3 := Array new: 7 withAll: nil.
	
	statement := client prepare: 'INSERT INTO table1 (p, c, b, l1, l2, p1, p2) VALUES ($1, $2, $3, $4, $5, $6, $7)'.
	statement executeBatch: { row1. row2. row3 }.
	
	result := client query: 'SELECT p, c, b, l1, l2, p1, p2 FROM table1 ORDER BY id'.

	self assert: result records equals: { row1. row2. row3 }.
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3PreparedStatementTest >> testInClause [
	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name) VALUES ($1,$2)'.
	statement executeBatch: #(
		( 1 'Hello World' )
		( 2 'Greetings' )
		( 3 'From Mars' )	).
	statement close.
	
	statement := client prepare: 'SELECT id, name FROM table1 WHERE id = ANY ($1) ORDER BY id'.

	result := statement query: { P3ValuesArray withAll: #( 2 3 ) }.
	self assert: result records equals: #( (2 'Greetings') (3 'From Mars') ).
	
	result := statement query: { P3ValuesArray withAll: #( 3 ) }.
	self assert: result records equals: #( (3 'From Mars') ).
	
	result := statement query: { P3ValuesArray withAll: #( 666 ) }.
	self assert: result records equals: #( ).
	
	statement close.
	client execute: 'DROP TABLE table1'.
]

{ #category : #tests }
P3PreparedStatementTest >> testInsertNull [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name) VALUES ($1,$2)'.
	result := statement executeBatch: #(
		( 123 'Hello World' )
		( 345 nil )
	).
	
	self assert: result size equals: 2.
	result do: [ :each |
		self assert: each equals: 'INSERT 0 1' ].
	
	statement close.
]

{ #category : #tests }
P3PreparedStatementTest >> testInterval [
	| statement intervals result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL, time_interval INTERVAL)'.
	
	intervals := { { P3Interval zero }. { P3Interval years: 1 months: 2 days: 3 hours: 4 minutes: 5 seconds: 6 } }.
	
	statement := client prepare: 'INSERT INTO table1 (time_interval) VALUES ($1)'.
	statement executeBatch: intervals.
	
	result := client query: 'SELECT time_interval FROM table1 ORDER BY id'.	
	self assert: result data equals: intervals.
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3PreparedStatementTest >> testLongQueries [
	"Test fix for issue: Prepared statements error when query is long and differs slightly at the end
	https://github.com/svenvc/P3/issues/20"

	| statement select1 select2 result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )	).
	statement close.
	
	select1 := client prepare: 'SELECT name, enabled FROM table1 /* long and boring piece of comment */ WHERE id >= $1 order by id'.
	select2 := client prepare: 'SELECT name, enabled FROM table1 /* long and boring piece of comment */ WHERE id < $1 order by id'.

	result := select1 query: #( 345 ).
	self assert: result records equals: #( ('Greetings' false) ('From Mars' true ) ).
	
	result := select2 query: #( 345 ).
	self assert: result records equals: #( ('Hello World' true ) ).
	self assert: select1 name size < 64.
	
	statement close.
	select1 close.
	select2 close.
]

{ #category : #tests }
P3PreparedStatementTest >> testMultipleInsertStatements [

	| statement1 statement2 |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT)'.

	client execute: 'DROP TABLE IF EXISTS table2'.
	client execute: 'CREATE TABLE table2 (id INTEGER, enabled BOOLEAN)'.

	statement1 := client prepare: 'INSERT INTO table1 (id, name) VALUES ($1,$2)'.
	statement2 := client prepare: 'INSERT INTO table2 (id, enabled) VALUES ($1,$2)'.
	
	statement1 execute: #( 22 'Hi!' ).
	statement2 executeBatch: #( ( 44 false ) ( 55 true ) ).

	statement1 close.
	statement2 close.
	

]

{ #category : #tests }
P3PreparedStatementTest >> testNamedPreparedStatement [
	| result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	client 
		prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'
		named: 'table1_insert1'.
	(client preparedStatementNamed: 'table1_insert1') executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )	).
	(client preparedStatementNamed: 'table1_insert1') close.
	self should: [ client preparedStatementNamed: 'table1_insert1' ] raise: NotFound.
	
	client 
		prepare: 'SELECT name, enabled FROM table1 where id >= $1 order by id'
		named: 'table1_select1'.

	result := (client preparedStatementNamed: 'table1_select1') query: #( 345 ).
	self assert: result records equals: #( ('Greetings' false) ('From Mars' true ) ).
	
	result := (client preparedStatementNamed: 'table1_select1') query: #( 567 ).
	self assert: result records equals: #( ('From Mars' true ) ).
	
	result := (client preparedStatementNamed: 'table1_select1') query: #( 800 ).
	self assert: result records equals: #( ).
	
	(client preparedStatementNamed: 'table1_select1') close.
]

{ #category : #tests }
P3PreparedStatementTest >> testScaledDecimal [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, nr NUMERIC(10,2))'.
	
	statement := client prepare: 'INSERT INTO table1 (id, nr) VALUES ($1,$2)'.
	statement execute: #( 10 100 ).
	statement execute: #( 20 100.12 ).
	statement execute: #( 30 100.12s2 ).
	statement execute: #( 40 100.123s2 ).
	statement execute: #( 50 100.129s2 ).
	statement close.
	
	statement := client prepare: 'SELECT nr FROM table1 ORDER BY id'.
	result := statement query: #( ).
	statement close.
	
	self assert: (result data collect: [ :row | row first asScaledDecimal ]) asArray
		equals: #( 100 100.12s2 100.12s2 100.12s2 100.13s2 ).
	


]

{ #category : #tests }
P3PreparedStatementTest >> testSelectStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )	).
	statement close.
	
	statement := client prepare: 'SELECT name, enabled FROM table1 where id >= $1 order by id'.

	result := statement query: #( 345 ).
	self assert: result records equals: #( ('Greetings' false) ('From Mars' true ) ).
	
	result := statement query: #( 567 ).
	self assert: result records equals: #( ('From Mars' true ) ).
	
	result := statement query: #( 800 ).
	self assert: result records equals: #( ).
	
	statement close.
]

{ #category : #tests }
P3PreparedStatementTest >> testSimpleInsertStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.

	statement execute: #( 123 'Hello World' true ).
	statement execute: #( 345 'Greetings' false ).
	
	statement executeBatch: #(
		#( 111 'Hello Mars' true )
		#( 333 'Hello Moon' false ) ).
	statement close.
	
	result := client query: 'SELECT id, name, enabled FROM table1 ORDER BY id'.
	self assert: result records size equals: 4.
]
