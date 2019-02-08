"
I am P3FormattedStatement, an SQL template with placeholders that, together with arguments, can be executed.

I am a tool to safely and more easily create SQL statements and queries that contain arguments. I know the correct textual representation of a set of primitive types. I do proper string escaping.

Since I know the client that created me, I can be executed autonomously.

You create instances of me by sending #format: to a P3Client instance.

For example,

	statement := client format: 'SELECT name, enabled FROM table1 WHERE id >= $1 ORDER BY id'.
	result := statement query: #( 345 ).

in the above 345 will be bound to (and replace) $1 in the SQL template.

The syntax that I use ($n) and my public API is mostly polymorphic with P3PreparedStatement. The difference is that I do simple string processing on the client without any interaction with the server.

"
Class {
	#name : #P3FormattedStatement,
	#superclass : #Object,
	#instVars : [
		'client',
		'sql'
	],
	#category : #'P3-Core'
}

{ #category : #private }
P3FormattedStatement >> bind: arguments [
	"Build and return the actual SQL statement by splicing in the arguments for all placeholders in the template"
	
	^ String streamContents: [ :out | | readStream |
			readStream := sql readStream.
			[ readStream atEnd ] whileFalse: [ | char |
				(char := readStream next) = $$
					ifTrue: [ | index argument |
						index := Integer readFrom: readStream.
						argument := arguments at: index.
						argument p3PrintUsing: self on: out ]
					ifFalse: [ out nextPut: char ] ] ]
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

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printBitString: bitString on: stream [
	"Use the B'0101' syntax for bit strings"
	
	stream nextPut: $B; nextPut: $'; print: bitString; nextPut: $'
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printByteArray: byteArray on: stream [
	"Use the bytea Hex Format for bytes (ByteArray),
	as in '\xDEADBEEF'"
	
	| hex |
	stream nextPutAll: '''\x'.
	hex := '0123456789ABCDEF'.
	byteArray do: [ :byte | 
		stream 
			nextPut: (hex at: (byte bitShift: -4) + 1);
			nextPut: (hex at: (byte bitAnd: 15) + 1) ].
	stream nextPut: $'
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printGeometricObject: geometricObject on: stream [
	"Delegate to P3GeometricObject that knows how to print itself in typed quoted PSQL text format"
	
	geometricObject printPsqlOn: stream
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printInterval: interval on: stream [
	"Delegate partially to P3Interval that knows how to print itself in postgresql style"
	
	stream nextPutAll: #interval; space; nextPut: $'; print: interval; nextPut: $'
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printNullOn: stream [
	"nil becomes NULL"
	
	stream nextPutAll: 'NULL'
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printObject: object on: stream [
	"In general, just use the standard print string representation"
	
	object printOn: stream 
]

{ #category : #printing }
P3FormattedStatement >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; << sql; nextPut: $)
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printScaledDecimal: scaledDecimal on: stream [
	"For ScaledDecimals, use a regular floating point like representation"
	
	scaledDecimal 
		printOn: stream 
		showingDecimalPlaces: scaledDecimal scale
]

{ #category : #'printing-dispatched' }
P3FormattedStatement >> printString: string on: stream [
	"For strings use single quotes and the doubling of single quotes when they are part of the string"
	
	stream nextPut: $'.
	string do: [ :each |
		each = $' ifTrue: [ stream nextPut: $' ].
		stream nextPut: each ].
	stream nextPut: $'
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
