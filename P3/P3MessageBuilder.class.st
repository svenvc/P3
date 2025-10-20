"
I am P3MessageBuilder.

I am a helper class used to construct binary messages.
"
Class {
	#name : 'P3MessageBuilder',
	#superclass : 'Object',
	#instVars : [
		'encoder',
		'byteStream'
	],
	#category : 'P3-Support',
	#package : 'P3',
	#tag : 'Support'
}

{ #category : 'instance creation' }
P3MessageBuilder class >> newWithEncoder: anEncoder [
	^ self new initWithEncoder: anEncoder
]

{ #category : 'converting' }
P3MessageBuilder >> asBytes [
	^ byteStream contents
]

{ #category : 'initialization' }
P3MessageBuilder >> initWithEncoder: anEncoder [

	byteStream := WriteStream on: (ByteArray new: 200).
	encoder := anEncoder
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutByte: anInteger [

	byteStream nextPut: anInteger
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutInt16: anInteger [

	2 to: 1 by: -1 do: [ :index | byteStream nextPut: (anInteger byteAt: index) ]
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutInt32: anInteger [

	4 to: 1 by: -1 do: [ :index | byteStream nextPut: (anInteger byteAt: index) ]
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutNullParameter [
	"Write a NULL Parameter"

	byteStream nextPutAll: #[255 255 255 255]
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutParameterAsText: aValue description: paramDescription [

	| sizePosition endPosition |
	
	sizePosition := byteStream position.
	byteStream nextPutAll: #[ 0 0 0 0 ]. "placeholder"
	aValue p3PrintUsing: self on: (ZnCharacterWriteStream on: byteStream encoding: encoder).
	endPosition := byteStream position.

	"Go back and set the correct size"
	byteStream position: sizePosition.
	byteStream uint32: (endPosition - sizePosition - 4).
	byteStream position: endPosition
]

{ #category : 'writing' }
P3MessageBuilder >> nextPutString: aString [

	aString do: [ :each | encoder nextPut: each toStream: byteStream ].
	byteStream nextPut: 0
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printBitString: bitString on: stream [
	"Delegate to P3[Fixed]BitString that knows how to print itself in unescaped, raw PSQL text format"
	
	bitString printOn: stream
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printByteArray: byteArray on: stream [
	"Use the bytea Hex Format for bytes (ByteArray), as in \xDEADBEEF"
	
	| hex |
	stream nextPutAll: '\x'.
	hex := '0123456789ABCDEF'.
	byteArray do: [ :byte | 
		stream 
			nextPut: (hex at: (byte bitShift: -4) + 1);
			nextPut: (hex at: (byte bitAnd: 15) + 1) ]
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printDate: date on: stream [
	"Use ISO 8601 YYYY-MM-DD"
	
	stream nextPut: $'.
	date printOn: stream format: #(3 2 1 $- 1 1 2).
	stream nextPut: $'
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printDateAndTime: dateAndTime on: stream [
	"Use ISO 8601 YYYY-MM-DDThh:mm:ss.s+ZZ:zz"
	
	stream nextPut: $'.
	dateAndTime printOn: stream.
	stream nextPut: $' 
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printGeometricObject: geometricObject on: stream [
	"Delegate to P3GeometricObject that knows how to print itself in unescaped, raw PSQL text format"
	
	geometricObject printOn: stream
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printInterval: interval on: stream [
	"Delegate to P3Interval that knows how to print itself in postgresql style"
	
	stream print: interval
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printNullOn: stream [
	"This cannot happen since nil is already handled earlier,
	see P3PreparedStatement>>#bindStrings:"
	
	self shouldNotImplement 
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printObject: object on: stream [
	"In general, just use the standard print string representation"
	
	object printOn: stream 
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printScaledDecimal: scaledDecimal on: stream [
	"For ScaledDecimals, use a regular floating point like representation"
	
	scaledDecimal 
		printOn: stream 
		showingDecimalPlaces: scaledDecimal scale
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printString: string on: stream [
	"For strings just output the characters of the string, no escaping is needed"
	
	stream nextPutAll: string
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printTime: time on: stream [
	"Use ISO 8601 hh:mm:ss"
	
	stream nextPut: $'.
	time print24: true on: stream.
	stream nextPut: $'
]

{ #category : 'printing-dispatched' }
P3MessageBuilder >> printValuesArray: valuesArray on: stream [
	| first |
	first := true.
	stream nextPut: ${.
	valuesArray do: [ :each |
		first ifTrue: [ first := false ] ifFalse: [ stream nextPut: $, ].
		each p3PrintUsing: self on: stream ].
	stream nextPut: $}
]

{ #category : 'writing' }
P3MessageBuilder >> writeTo: aConnection tag: aChar [

	aConnection nextPut: aChar asInteger.

]
