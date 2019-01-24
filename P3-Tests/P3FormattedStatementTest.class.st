"
P3FormattedStatementTest holds unit tests for the P3FormattedStatement class.

I reuse the configuration of P3ClientTests.
"
Class {
	#name : #P3FormattedStatementTest,
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
P3FormattedStatementTest >> setUp [
	super setUp.
	client := P3Client new.
	client url: P3ClientTest url.
	client connect
]

{ #category : #running }
P3FormattedStatementTest >> tearDown [
	client close.
	super tearDown
]

{ #category : #tests }
P3FormattedStatementTest >> testSimple [
	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client format: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	statement executeBatch: #(
		( 123 'Hello World' true )
		( 345 'Greetings' false )
		( 567 'From Mars' true )	).
	
	statement := client format: 'SELECT name, enabled FROM table1 WHERE id >= $1 ORDER BY id'.

	result := statement query: #( 345 ).
	self assert: result records equals: #( ('Greetings' false) ('From Mars' true ) ).
	
	result := statement query: #( 567 ).
	self assert: result records equals: #( ('From Mars' true ) ).
	
	result := statement query: #( 800 ).
	self assert: result records equals: #( ).
]
