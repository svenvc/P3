"
I am P3ConnectionEstablishedEvent.
I am a P3LogEvent.

I represent the opening of a PostgreSQL client connection.

I hold a copy of the settings and properties of the P3Client.
"
Class {
	#name : #P3ConnectionEstablishedEvent,
	#superclass : #P3LogEvent,
	#instVars : [
		'settings',
		'properties'
	],
	#category : #'P3-Logging'
}

{ #category : #accessing }
P3ConnectionEstablishedEvent >> authenticationType [
	^ self properties 
		at: #'authentication_type' 
		ifPresent: [ :authenticationType |
			authenticationType = #Ok
				ifTrue: [ #Trust ]
				ifFalse: [ authenticationType ] ]
		ifAbsent: [ nil ]
]

{ #category : #initialization }
P3ConnectionEstablishedEvent >> clearPassword [
	settings removeKey: #password
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> database [
	^ settings at: #database ifAbsent: [ nil ]
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> host [
	^ settings at: #host ifAbsentPut: [ 'localhost' ]
]

{ #category : #testing }
P3ConnectionEstablishedEvent >> isSSL [
	^ settings at: #ssl ifAbsent: [ false ]
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> password [
	^ settings at: #password ifAbsent: [ nil ]
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> port [
	^ settings at: #port ifAbsentPut: [ 5432 ]
]

{ #category : #printing }
P3ConnectionEstablishedEvent >> printContentsOn: stream [
	stream print: #Connect.
	stream space; nextPutAll: 'psql://'.
	self user ifNotNil: [ :user | stream nextPutAll: user; nextPut: $@ ].
	stream nextPutAll: self host; nextPut: $:; print: self port.
	self database ifNotNil: [ :database | stream nextPut: $/; nextPutAll: database ].
	self isSSL ifTrue: [ stream nextPutAll: '?sslmode=require' ].
	self authenticationType ifNotNil: [ :type | stream space; nextPutAll: type ]
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> properties [
	^ properties
]

{ #category : #initialization }
P3ConnectionEstablishedEvent >> properties: anObject [
	properties := anObject
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> settings [
	^ settings
]

{ #category : #initialization }
P3ConnectionEstablishedEvent >> settings: anObject [
	settings := anObject
]

{ #category : #accessing }
P3ConnectionEstablishedEvent >> user [
	^ settings at: #user ifAbsent: [ nil ]
]
