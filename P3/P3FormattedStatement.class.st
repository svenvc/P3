"
I am P3FormattedStatement, an SQL template with placeholders that, together with arguments, can be executed.

I am a tool to safely and more easily create SQL statements and queries that contain arguments. I know the correct textual representation of a set of primitive types. I do proper string escaping.

You create instances of me by sending #format: to a P3Client instance.

For example,

	statement := client format: 'SELECT name, enabled FROM table1 WHERE id >= $1 ORDER BY id'.
	result := statement query: #( 345 ).

in the above 345 will be bound to (and replace) $1 in the SQL template.

Since I know the client that created me, I can be executed autonomously.

The syntax that I use ($n) and my public API is mostly polymorphic with P3PreparedStatement. The difference is that I do simple string processing on the client without any interaction with the server.

"
Class {
	#name : #P3FormattedStatement,
	#superclass : #Object,
	#instVars : [
		'client',
		'sql'
	],
	#category : #P3
}

{ #category : #private }
P3FormattedStatement >> bind: arguments [
	^ String streamContents: [ :out | | readStream |
			readStream := sql readStream.
			[ readStream atEnd ] whileFalse: [ | currentChar |
				(currentChar := readStream next) = $$
					ifTrue: [ | index |
						index := Integer readFrom: readStream.
						self printArgument: (arguments at: index) on: out ]
					ifFalse: [ out nextPut: currentChar ] ] ]
]

{ #category : #initialization }
P3FormattedStatement >> client: aP3Client [
	client := aP3Client
]

{ #category : #public }
P3FormattedStatement >> execute: arguments [
	"Bind the arguments given to the placeholders in my SQL template and
	execute this statement using my client, returning the result"

	^ client execute: (self bind: arguments)
]

{ #category : #public }
P3FormattedStatement >> executeBatch: argumentsCollection [
	"Bind each set of arguments from the argumentsCollection given
	to the placeholders in my SQL template and execute this statement using my client, 
	returning the collection of results"

	^ argumentsCollection collect: [ :each | self execute: each ]
]

{ #category : #private }
P3FormattedStatement >> printArgument: argument on: stream [
	argument printOn: stream
]

{ #category : #printing }
P3FormattedStatement >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; << sql; nextPut: $)
]

{ #category : #public }
P3FormattedStatement >> query: arguments [
	"Bind the arguments given to the placeholders in my SQL template and
	execute this query using my client, returning the result"
	
	^ client query: (self bind: arguments)
]

{ #category : #public }
P3FormattedStatement >> queryAll: argumentsCollection [
	"Bind each set of arguments from the argumentsCollection given
	to the placeholders in my SQL template and execute this query using my client, 
	returning the collection of results"

	^ argumentsCollection collect: [ :each | self query: each ]
]

{ #category : #initialization }
P3FormattedStatement >> sql: anSQLTemplateString [
	sql := anSQLTemplateString 
]
