"
I am P3StatementBoundEvent.
I am a P3LogEvent.

I represent binding of a previously prepared P3PreparedStatement.

Note that I hold all data used.
"
Class {
	#name : 'P3StatementBoundEvent',
	#superclass : 'P3LogEvent',
	#instVars : [
		'statement',
		'inputValues'
	],
	#category : 'P3-Logging',
	#package : 'P3',
	#tag : 'Logging'
}

{ #category : 'accessing' }
P3StatementBoundEvent >> inputValues [
	^ inputValues
]

{ #category : 'initialization' }
P3StatementBoundEvent >> inputValues: anObject [
	inputValues := anObject
]

{ #category : 'printing' }
P3StatementBoundEvent >> printContentsOn: stream [
	stream print: #Bind.
	stream space.
	self statement name do: [ :each |
		(String crlf includes: each) 
			ifTrue: [ stream space ]
			ifFalse: [ stream nextPut: each ] ].
	stream 
		nextPutAll: ', ';  
		print: self statement paramCount; 
		nextPutAll: (' value' asPluralBasedOn: self statement paramCount)
]

{ #category : 'accessing' }
P3StatementBoundEvent >> statement [
	^ statement
]

{ #category : 'initialization' }
P3StatementBoundEvent >> statement: anObject [
	statement := anObject
]
