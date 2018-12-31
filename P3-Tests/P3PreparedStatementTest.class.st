"
P3PreparedStatementTest holds unit tests for the P3PreparedStatement class.

I reuse the configuration of P3ClientTests. Example:

  P3ClientTests url: 'psql://sven:secret@localhost:5432/database'.
"
Class {
	#name : #P3PreparedStatementTest,
	#superclass : #TestCase,
	#instVars : [
		'client'
	],
	#classVars : [
		'Url'
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
	statement execute: #( 123 #[ 100 102 104 106 108 ] ).
	statement execute: #( 345 #[ 100 102 104 106 108 100 102 104 106 108 ]  ).
	statement close.
	
	statement := client prepare: 'SELECT bytes from table1 WHERE id = $1'.
	result := statement queryAll: #( ( 123 ) ( 345 ) ).
	statement close.

	self assert: #( #[ 100 102 104 106 108 ] ) equals: (result at: 1) firstRecord.
	self assert: #( #[ 100 102 104 106 108 100 102 104 106 108 ] ) equals: (result at: 2) firstRecord.
	
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
