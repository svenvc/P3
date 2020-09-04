"
I am P3DatabaseDriver, a Glorp Database Driver using the P3Client for PostgreSQL.

Installation

  PharoDatabaseAccessor DefaultDriver: P3DatabaseDriver.

Configure your session using a Glorp Login object

  Login new
    database: PostgreSQLPlatform new;
    username: 'username';
    password: 'password';
    connectString: 'host:5432_databasename';
    encodingStrategy: #utf8;
    yourself.
"
Class {
	#name : #P3DatabaseDriver,
	#superclass : #DatabaseDriver,
	#instVars : [
		'rowCount'
	],
	#category : #'P3-Glorp'
}

{ #category : #executing }
P3DatabaseDriver >> basicExecuteSQLString: aString [
	| result |
	result := connection query: aString.
	rowCount := result totalRowCount.
	^ (result hasData ifTrue: [ result data ] ifFalse: [ #() ]) readStream
]

{ #category : #transactions }
P3DatabaseDriver >> beginTransaction [
	connection execute: 'BEGIN TRANSACTION'
]

{ #category : #transactions }
P3DatabaseDriver >> commitTransaction [
	connection execute: 'COMMIT TRANSACTION'
]

{ #category : #accessing }
P3DatabaseDriver >> connect: aLogin [
	connection := self connectionClass new.
	connection 
		host: aLogin host;
		port: aLogin port asInteger;
		database: aLogin databaseName;
		user: aLogin username;
		password: aLogin password.
	connection connect
]

{ #category : #accessing }
P3DatabaseDriver >> connectSSL: aLogin [
	connection := self connectionClass new.
	connection
		setSSL;
		host: aLogin host;
		port: aLogin port asInteger;
		database: aLogin databaseName;
		user: aLogin username;
		password: aLogin password.
	connection connectSSL
]

{ #category : #accessing }
P3DatabaseDriver >> connectionClass [
	^ P3Client
]

{ #category : #testing }
P3DatabaseDriver >> isConnected [
	^ connection notNil and: [ connection isConnected ]
]

{ #category : #login }
P3DatabaseDriver >> logout [
	connection ifNotNil: [ 
		connection close.
		connection := nil ]
]

{ #category : #transactions }
P3DatabaseDriver >> rollbackTransaction [
	connection execute: 'ROLLBACK TRANSACTION'
]

{ #category : #accessing }
P3DatabaseDriver >> rowCount [
	^ rowCount
]
