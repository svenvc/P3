"
I am P3MessageBuilder.

I am a helper class used to construct binary messages.
"
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
P3MessageBuilder >> nextPutNullParameter [
	"Write a NULL Parameter"

	byteStream nextPutAll: #[255 255 255 255]
]

{ #category : #writing }
P3MessageBuilder >> nextPutParameterAsText: aValue description: paramDescription [

	| sizePosition endPosition |
	
	sizePosition := byteStream position.
	byteStream nextPutAll: #[ 0 0 0 0 ]. "placeholder"
	aValue printAsP3TextOn: (ZnCharacterWriteStream on: byteStream encoding: encoder).
	endPosition := byteStream position.

	"Go back and set the correct size"
	byteStream position: sizePosition.
	byteStream uint32: (endPosition - sizePosition - 4).
	byteStream position: endPosition
]

{ #category : #writing }
P3MessageBuilder >> nextPutString: aString [

	aString do: [ :each | encoder nextPut: each toStream: byteStream ].
	byteStream nextPut: 0
]

{ #category : #writing }
P3MessageBuilder >> writeTo: aConnection tag: aChar [

	aConnection nextPut: aChar asInteger.

]
