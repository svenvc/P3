"
I am P3MessageBuffer.

I am a reusable buffer to hold a single protocol message read.

I try to prevent allocations as much as possible.
I grow as needed.
"
Class {
	#name : #P3MessageBuffer,
	#superclass : #Object,
	#instVars : [
		'tag',
		'payload',
		'size'
	],
	#category : 'P3'
}

{ #category : #accessing }
P3MessageBuffer >> capacity [
	^ self rawByteBuffer size
]

{ #category : #initialization }
P3MessageBuffer >> initialize [
	super initialize.
	self initializeForSize: 0
]

{ #category : #initialization }
P3MessageBuffer >> initializeForSize: actualSize [
	(payload isNil or: [ actualSize > self capacity ])
		ifTrue: [ payload := (ByteArray new: ((actualSize // 1024) + 1) * 1024) readStream ].
	size := actualSize.
	payload setFrom: 1 to: size
]

{ #category : #accessing }
P3MessageBuffer >> payloadCopy [
	^ self rawByteBuffer copyFrom: 1 to: size
]

{ #category : #accessing }
P3MessageBuffer >> rawByteBuffer [
	^ payload originalContents
]

{ #category : #initialization }
P3MessageBuffer >> readFrom: readStream [
	| length |
	self tag: readStream next asCharacter.
	length := (self uint32From: readStream) - 4.
	self initializeForSize: length.
	readStream next: self size into: self rawByteBuffer
]

{ #category : #accessing }
P3MessageBuffer >> readStream [
	^ payload
]

{ #category : #accessing }
P3MessageBuffer >> size [
	^ size
]

{ #category : #accessing }
P3MessageBuffer >> tag [
	^ tag
]

{ #category : #initialization }
P3MessageBuffer >> tag: character [
	tag := character
]

{ #category : #reading }
P3MessageBuffer >> uint32From: stream [
	| uint32 |
	uint32 := stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	^ uint32
]
