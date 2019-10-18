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

{ #category : #testing }
P3FormattedStatementTest >> isServerVersionAtLeastMajor: major minor: minor [
	| serverVersion |
	serverVersion := ($. split: client serverVersion) collect: #asNumber.
	^ serverVersion first > major
		or:
			[ serverVersion first = major and: [ serverVersion second >= minor ] ]
]

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
P3FormattedStatementTest >> testBitString [
	| statement bitString fixedBitString result |
	
	client execute: 'DROP TABLE IF EXISTS testBits'.
	client execute: 'CREATE TABLE testBits (id INT, b1 BIT, b2 BIT VARYING, b3 BIT(8), b4 BIT VARYING(8))'.
	
	bitString := P3BitString bits: 2r11001111.
	fixedBitString := P3FixedBitString bits: 2r11110011.
	
	statement := client format: 'INSERT INTO testBits (id, b1, b2, b3, b4) VALUES ($1, $2, $3, $4, $5)'.
	statement execute: { 100. P3FixedBitString one. bitString. fixedBitString. bitString }.
	
	statement := client format: 'SELECT b1, b2, b3, b4 FROM testBits WHERE id = $1'.
	result := statement query: #( 100 ).
	
	self assert: result firstRecord equals: { P3FixedBitString one. bitString. fixedBitString. bitString }.
	
	client execute: 'DROP TABLE testBits'
]

{ #category : #tests }
P3FormattedStatementTest >> testByteArray [
	| statement bytes result |
	
	client execute: 'DROP TABLE IF EXISTS testBytea'.
	client execute: 'CREATE TABLE testBytea (id INT, bytes BYTEA)'.
	
	bytes := #[ 0 1 2 3 4 254 255 ].	
	
	statement := client format: 'INSERT INTO testBytea (id, bytes) VALUES ($1, $2)'.
	statement execute: { 100. bytes }.
	
	statement := client format: 'SELECT bytes FROM testBytea WHERE id = $1'.
	result := statement query: #( 100 ).
	
	self assert: result firstFieldOfFirstRecord equals: bytes.
	
	client execute: 'DROP TABLE testBytea'
]

{ #category : #tests }
P3FormattedStatementTest >> testChronology [
	| result statement |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, timestamp_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP, date_created DATE DEFAULT CURRENT_DATE, time_created TIME DEFAULT CURRENT_TIME)'.
	statement := client format: 'INSERT INTO table1 (name) VALUES ($1)'.
	statement execute: { 'Chronology' }.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	self assert: result firstRecord second equals: 'Chronology'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	statement := client format: 'INSERT INTO table1 (name, timestamp_created, date_created, time_created) VALUES ($1, $2, $3, $4)'.
	statement execute: { 'Pharo'. DateAndTime now. Date today. Time now }.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 2'.
	self assert: result firstRecord first equals: 2.
	self assert: result firstRecord second equals: 'Pharo'.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (Date today - result firstRecord fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result firstRecord fifth asSeconds) abs < 30.
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3FormattedStatementTest >> testGeometricTypes [
	| p1 p2 p3 points row1 row2 row3 statement result |
	(self isServerVersionAtLeastMajor: 9 minor: 4) ifFalse: [ ^ self skip ].
	
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
	
	statement := client format: 'INSERT INTO table1 (p, c, b, l1, l2, p1, p2) VALUES ($1, $2, $3, $4, $5, $6, $7)'.
	statement executeBatch: { row1. row2. row3 }.
	
	result := client query: 'SELECT p, c, b, l1, l2, p1, p2 FROM table1 ORDER BY id'.

	self assert: result records equals: { row1. row2. row3 }.
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3FormattedStatementTest >> testInterval [
	| statement intervals result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL, time_interval INTERVAL)'.
	
	intervals := { { P3Interval zero }. { P3Interval years: 1 months: 2 days: 3 hours: 4 minutes: 5 seconds: 6 } }.
	
	statement := client format: 'INSERT INTO table1 (time_interval) VALUES ($1)'.
	statement executeBatch: intervals.
	
	result := client query: 'SELECT time_interval FROM table1 ORDER BY id'.	
	self assert: result data equals: intervals.
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3FormattedStatementTest >> testNull [
	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client format: 'INSERT INTO table1 (id, name, enabled) VALUES ($1, $2, $3)'.
	statement execute: #( nil nil nil	).
	
	result := client query: 'SELECT id, name, enabled FROM table1'.

	self assert: result firstRecord equals: #( nil nil nil ).
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3FormattedStatementTest >> testSimple [
	| statement result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	
	statement := client format: 'INSERT INTO table1 (id, name, enabled) VALUES ($1, $2, $3)'.
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
	
	client execute: 'DROP TABLE table1'
]

{ #category : #tests }
P3FormattedStatementTest >> testStrings [
	| statement string result |
	
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT)'.
	
	string := 'single '' dounble '' dollar $ backslash \ euro €'.
	
	statement := client format: 'INSERT INTO table1 (id, name) VALUES ($1, $2)'.
	statement execute: { 123. string }.
	
	statement := client format: 'SELECT name FROM table1 WHERE id = $1'.
	result := statement query: { 123 }.
	
	self assert: result firstFieldOfFirstRecord equals: string.
	
	client execute: 'DROP TABLE table1'
]
