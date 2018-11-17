Class {
	#name : #P3PreparedStatement,
	#superclass : #Object,
	#instVars : [
		'client',
		'name',
		'descriptions'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3PreparedStatement class >> newWith: aClient name: aString [

	^ self new initializeWith: aClient name: aString
]

{ #category : #'as yet unclassified' }
P3PreparedStatement >> bindStrings: inputValues [

	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder
		nextPutString: '';
		nextPutString: name;
		nextPutInt16: 0;
		nextPutInt16: inputValues size.
		
	inputValues do: [ :eachValue |
		msgBuilder nextPutStringParameter: eachValue ].

	msgBuilder 
		nextPutInt16: 0.	"All result columns use the text format"		
		
	client writeMessageNoFlush: msgBuilder asBytes tag: $B 

]

{ #category : #public }
P3PreparedStatement >> execute: inputRow [

	self bindStrings: inputRow.
	self writeExecuteMessage: 0.
	client writeSyncMessage.
	
	^ client runExtendedQueryResult
]

{ #category : #public }
P3PreparedStatement >> executeBatch: inputRows [

	inputRows do: [ :eachRow |
		self bindStrings: eachRow.
		self writeExecuteMessage: 0 ].
	client writeSyncMessage.
	
	^ client runExtendedQueryResult
]

{ #category : #initialization }
P3PreparedStatement >> initializeWith: aClient name: aString [

	client := aClient.
	name := aString.
]

{ #category : #public }
P3PreparedStatement >> query: inputRow [

	self bindStrings: inputRow.
	descriptions isNil
		ifTrue: [ self writeDescribeMessage: '' type: $P ].
	self writeExecuteMessage: 0.
	client writeSyncMessage.
	
	"Check for BindComplete message"
	client readMessage tag = $2
		ifFalse: [ ^ self error: 'Unexpected message. BindComplete expected' ].

	^ client runQueryResult
]

{ #category : #writing }
P3PreparedStatement >> writeDescribeMessage: aName type: aChar [
	"Type $S to describe a prepared statement; or $P to describe a portal."
	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder
		nextPutByte: aChar asInteger;
		nextPutString: aName.
	client writeMessageNoFlush: msgBuilder asBytes tag: $D
]

{ #category : #'as yet unclassified' }
P3PreparedStatement >> writeExecuteMessage: rowLimit [

	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder
		nextPutString: '';
		nextPutInt32: rowLimit.

	client writeMessageNoFlush: msgBuilder asBytes tag: $E
]
