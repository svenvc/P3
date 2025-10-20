"
I am P3StatementPreparedEvent.
I am a P3LogEvent.

I represent a P3PreparedStatement, an SQL query (statement) prepared (preparsed) by PostgreSQL.
"
Class {
	#name : 'P3StatementPreparedEvent',
	#superclass : 'P3LogEvent',
	#instVars : [
		'statement',
		'query'
	],
	#category : 'P3-Logging',
	#package : 'P3',
	#tag : 'Logging'
}

{ #category : 'printing' }
P3StatementPreparedEvent >> printContentsOn: stream [
	stream print: #Prepare.
	stream space.
	self query do: [ :each |
		(String crlf includes: each) 
			ifTrue: [ stream space ]
			ifFalse: [ stream nextPut: each ] ].
	stream 
		nextPutAll: ', '; 
		print: self statement paramCount;
		nextPutAll: (' parameter' asPluralBasedOn: self statement paramCount)
]

{ #category : 'accessing' }
P3StatementPreparedEvent >> query [
	^ query
]

{ #category : 'initialization' }
P3StatementPreparedEvent >> query: anObject [
	query := anObject
]

{ #category : 'accessing' }
P3StatementPreparedEvent >> statement [
	^ statement
]

{ #category : 'initialization' }
P3StatementPreparedEvent >> statement: anObject [
	statement := anObject
]
