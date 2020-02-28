"
I am P3PreparedStatement. Use me if you need to execute a query multiple times.

Create an instance of me via P3Client>>#prepare: The argument to this method is a query string that can contain one or more placeholders. When executing the statement an array should be provided with a value for each placeholder.

Examples:

Prepare an insert statement and execute it two times with different parameters:

	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	result := statement execute: #( 123 'Hello World' true ).
	result := statement execute: #( 45 'Greetings' false ).

It's also possible to execute the two inserts in a single network roundtrip:

	statement := client prepare: 'INSERT INTO table1 (id, name, enabled) VALUES ($1,$2,$3)'.
	results := statement executeBatch: #( 
		( 123 'Hello World' true )
		( 45 'Greetings' false ) ).

Select query:

	statement := client prepare: 'SELECT name, enabled FROM table1 WHERE id = $1'.
	result := statement query: #( 123 ).

When I'm no longer needed I should be closed so that the PostgreSQL server side resources for this prepared statemed are freed.

See also https://en.wikipedia.org/wiki/Prepared_statement

A prepared statement can be more efficient, especially if it is used multiple times. Prepared statements are also resilient against SQL injection attacks. On the server, prepared statements are bound to the current session.

My API and the syntax that I use ($n) is mostly polymorphic with P3FormattedStatement. The difference is that I do much more than textual processing: my SQL template is actually parsed on the server, checking the syntax and partially planning the execution, during the actual execution phase, just the concrete argument values are transferred, taking advantage of some of the work that has already been done on the server.
 

"
Class {
	#name : #P3PreparedStatement,
	#superclass : #Object,
	#instVars : [
		'client',
		'name',
		'paramDescriptions',
		'fieldDescriptions'
	],
	#category : #'P3-Core'
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

	inputValues
		with: paramDescriptions
		do: [ :eachValue :paramDescription | 
			eachValue
				ifNil: [ msgBuilder nextPutNullParameter ]
				ifNotNil: [ msgBuilder nextPutParameterAsText: eachValue description: paramDescription ]
			].

	msgBuilder nextPutInt16: 0.	"All result columns use the text format"

	client writeMessageNoFlush: msgBuilder asBytes tag: $B
]

{ #category : #public }
P3PreparedStatement >> close [
	"Close this query and release server side resources."

	client ifNil: [ ^ self ].

	self writeCloseMessage: name type: $S.
	self writeFlushMessage.	
	
	"Check for CloseComplete message"
	client readMessage tag = $3
		ifFalse: [ self error: 'CloseComplete message expected' ].	
	
	"This prepared statement can no longer be used."
	client forgetPreparedStatementNamed: name.
	client := nil
]

{ #category : #accessing }
P3PreparedStatement >> converter [ 
	^ client converter
]

{ #category : #public }
P3PreparedStatement >> execute: inputRow [
	"Execute this SQL query with inputRow as the ordered collection of parameters.
	Assume no rows will be returned."

	self bindStrings: inputRow.
	self writeExecuteMessage: 0.
	client writeSyncMessage.
	
	^ (client runExtendedQueryResults: fieldDescriptions) first result
]

{ #category : #public }
P3PreparedStatement >> executeBatch: inputRows [
	"Execute this SQL query mutiple (inputRow size) times in a single network roundtrip.
	Assume no rows will be returned."

	inputRows isEmpty
		ifTrue: [ ^ #() ].

	inputRows do: [ :eachRow |
		self bindStrings: eachRow.
		self writeExecuteMessage: 0 ].
	client writeSyncMessage.
	
	^ (client runExtendedQueryResults: fieldDescriptions) collect: [ :each | each result ]
]

{ #category : #accessing }
P3PreparedStatement >> fieldCount [
	^ fieldDescriptions size
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
P3PreparedStatement >> paramCount [
	^ paramDescriptions size
]

{ #category : #accessing }
P3PreparedStatement >> paramDescriptions [
	^ paramDescriptions
]

{ #category : #printing }
P3PreparedStatement >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; << name; nextPut: $)
]

{ #category : #public }
P3PreparedStatement >> query: inputRow [
	"Execute this SQL query with inputRow as the ordered collection of parameters.
	Answer a P3Result object with the field descriptions and rows."

	self bindStrings: inputRow.
	self writeExecuteMessage: 0.
	client writeSyncMessage.
	
	^ (client runExtendedQueryResults: fieldDescriptions) first
]

{ #category : #public }
P3PreparedStatement >> queryAll: inputRows [
	"Execute this SQL query multiple times.
	Answer a collection of P3Result objects with the field descriptions and rows."

	inputRows isEmpty
		ifTrue: [ ^ #() ].

	inputRows do: [ :eachRow |
		self bindStrings: eachRow.
		self writeExecuteMessage: 0 ].
	client writeSyncMessage.
	
	^ client runExtendedQueryResults: fieldDescriptions
]

{ #category : #'input/output' }
P3PreparedStatement >> writeCloseMessage: aName type: aChar [

	| msgBuilder |
	msgBuilder := client newMessageBuilder.
	msgBuilder 
		nextPutByte: aChar asInteger;
		nextPutString: aName.
	client writeMessageNoFlush: msgBuilder asBytes tag: $C
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

{ #category : #'input/output' }
P3PreparedStatement >> writeFlushMessage [
	client writeMessage: #[] tag: $H
]
