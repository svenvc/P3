Class {
	#name : #P3PreparedStatement,
	#superclass : #Object,
	#instVars : [
		'client',
		'name',
		'paramDescriptions',
		'fieldDescriptions'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3PreparedStatement class >> newWith: aClient name: aString parameters: paramDescriptions fields: rowDescriptions [

	^ self new initializeWith: aClient name: aString parameters: paramDescriptions fields: rowDescriptions
]

{ #category : #'input/output' }
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
	
	^ client runExtendedQueryResult: fieldDescriptions
]

{ #category : #public }
P3PreparedStatement >> executeBatch: inputRows [

	inputRows do: [ :eachRow |
		self bindStrings: eachRow.
		self writeExecuteMessage: 0 ].
	client writeSyncMessage.
	
	^ client runExtendedQueryResult: fieldDescriptions
]

{ #category : #accessing }
P3PreparedStatement >> fieldDescriptions [
	^ fieldDescriptions
]

{ #category : #initialization }
P3PreparedStatement >> initializeWith: aClient name: aString parameters: aParamDescriptions fields: aRowFieldDescriptions [

	client := aClient.
	name := aString.
	paramDescriptions := aParamDescriptions.
	fieldDescriptions := aRowFieldDescriptions
]

{ #category : #accessing }
P3PreparedStatement >> name [
	^ name
]

{ #category : #accessing }
P3PreparedStatement >> paramDescriptions [
	^ paramDescriptions
]

{ #category : #public }
P3PreparedStatement >> query: inputRow [

	| result |
	self bindStrings: inputRow.
	self writeExecuteMessage: 0.
	client writeSyncMessage.
	
	result := client runExtendedQueryResult: fieldDescriptions.
	^ result data
]

{ #category : #'input/output' }
P3PreparedStatement >> writeDescribeMessage: aName type: aChar [
	"Type $S to describe a prepared statement; or $P to describe a portal."
	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder
		nextPutByte: aChar asInteger;
		nextPutString: aName.
	client writeMessageNoFlush: msgBuilder asBytes tag: $D
]

{ #category : #'input/output' }
P3PreparedStatement >> writeExecuteMessage: rowLimit [

	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder
		nextPutString: '';
		nextPutInt32: rowLimit.

	client writeMessageNoFlush: msgBuilder asBytes tag: $E
]
