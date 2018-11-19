Class {
	#name : #P3PreparedStatementTests,
	#superclass : #TestCase,
	#instVars : [
		'client'
	],
	#classVars : [
		'Url'
	],
	#category : #P3
}

{ #category : #running }
P3PreparedStatementTests >> setUp [
	super setUp.
	client := P3Client new.
	client url: P3ClientTests url.
	client timeout: 10. "second"
	client connect
]

{ #category : #running }
P3PreparedStatementTests >> tearDown [
	client close.
	super tearDown
]

{ #category : #tests }
P3PreparedStatementTests >> testBatchInsertStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	"self assert: client isWorking."
	
	result := statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )
	).
	
	result inspect.

]

{ #category : #tests }
P3PreparedStatementTests >> testMultipleInsertStatement [

	| result statement1 statement2 |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.

	client execute: 'DROP TABLE IF EXISTS table2'.
	client execute: 'CREATE TABLE table2 (id INTEGER, name TEXT, enabled BOOLEAN)'.

	statement1 := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	statement2 := client prepare: 'INSERT INTO table2 (id, name, enabled) VALUES ($1,$2,$3)'.
	self assert: client isWorking.

	

]

{ #category : #tests }
P3PreparedStatementTests >> testSelectStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )	).
	
	statement := client prepare: 'SELECT name, enabled FROM table1 where id >= $1 order by id'.

	result := statement query: #( 345 ).
	self assert: result equals: #( ('Greetings' false) ('From Mars' true ) ).
	
	result := statement query: #( 567 ).
	self assert: result equals: #( ('From Mars' true ) ).
	
	result := statement query: #( 800 ).
	self assert: result equals: #( ).
]

{ #category : #tests }
P3PreparedStatementTests >> testSimpleInsertStatement [

	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	"self assert: client isWorking."
	
	result := statement execute: #( 123 'Hello World' true ).
	result := statement execute: #( 345 'Greetings' false ).
	
	result inspect.

]

{ #category : #tests }
P3PreparedStatementTests >> testSimpleSelectStatement [

	| statement result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (NULL, NULL, NULL)'.

	statement := client prepare: 'SELECT id, name, enabled FROM table1'.

	result := statement query: #().

]
