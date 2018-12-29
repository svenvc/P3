Class {
	#name : #P3MessageBuilder,
	#superclass : #Object,
	#instVars : [
		'encoder',
		'byteStream'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3MessageBuilder class >> newWithEncoder: anEncoder [
	^ self new initWithEncoder: anEncoder
]

{ #category : #converting }
P3MessageBuilder >> asBytes [
	^ byteStream contents
]

{ #category : #initialization }
P3MessageBuilder >> initWithEncoder: anEncoder [

	byteStream := WriteStream on: (ByteArray new: 200).
	encoder := anEncoder
]

{ #category : #writing }
P3MessageBuilder >> nextPutByte: anInteger [

	byteStream nextPut: anInteger
]

{ #category : #writing }
P3MessageBuilder >> nextPutInt16: anInteger [

	2 to: 1 by: -1 do: [ :index | byteStream nextPut: (anInteger digitAt: index) ]
]

{ #category : #writing }
P3MessageBuilder >> nextPutInt32: anInteger [

	4 to: 1 by: -1 do: [ :index | byteStream nextPut: (anInteger digitAt: index) ]
]

{ #category : #writing }
P3MessageBuilder >> nextPutString: aString [

	aString do: [ :each | encoder nextPut: each toStream: byteStream ].
	byteStream nextPut: 0
]

{ #category : #writing }
P3MessageBuilder >> nextPutStringParameter: aValueOrNil [
	"Write a Parameter in the text format."

	aValueOrNil isNil
		ifTrue: [ 
			self nextPutInt32: -1 ]
		ifFalse: [ 
			| bytes |
			bytes := encoder encodeString: aValueOrNil asString.
			self nextPutInt32: bytes size.
			byteStream nextPutAll: bytes ]
]

{ #category : #writing }
P3MessageBuilder >> writeTo: aConnection tag: aChar [

	aConnection nextPut: aChar asInteger.

]
