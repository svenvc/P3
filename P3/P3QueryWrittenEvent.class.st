"
I am P3QueryWrittenEvent.
I am a P3LogEvent.

I represent an SQL query (statement) that was sent to PostgreSQL.
"
Class {
	#name : 'P3QueryWrittenEvent',
	#superclass : 'P3LogEvent',
	#instVars : [
		'query'
	],
	#category : 'P3-Logging',
	#package : 'P3',
	#tag : 'Logging'
}

{ #category : 'printing' }
P3QueryWrittenEvent >> printContentsOn: stream [
	stream print: #Query.
	stream space.
	self query do: [ :each |
		(String crlf includes: each) 
			ifTrue: [ stream space ]
			ifFalse: [ stream nextPut: each ] ]
]

{ #category : 'accessing' }
P3QueryWrittenEvent >> query [
	^ query
]

{ #category : 'initialization' }
P3QueryWrittenEvent >> query: anObject [
	query := anObject
]
