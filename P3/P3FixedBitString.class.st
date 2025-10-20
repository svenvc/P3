"
I am P3FixedBitString.
I am a P3BitString.

I represent the BIT(N) type, with a fixed length/size.
"
Class {
	#name : 'P3FixedBitString',
	#superclass : 'P3BitString',
	#instVars : [
		'size'
	],
	#category : 'P3-Objects',
	#package : 'P3',
	#tag : 'Objects'
}

{ #category : 'instance creation' }
P3FixedBitString class >> bits: integer [
	^ self bits: integer count: (integer highBit max: 1)
]

{ #category : 'instance creation' }
P3FixedBitString class >> bits: integer count: count [
	^ self new 
		bits: integer;
		size: count;
		yourself
]

{ #category : 'comparing' }
P3FixedBitString >> = anotherFixedBitString [
	self == anotherFixedBitString ifTrue: [ ^ true ].
	self class = anotherFixedBitString class ifFalse: [ ^ false ].
	^ bits = anotherFixedBitString bits and: [ size = anotherFixedBitString size ]
]

{ #category : 'accessing' }
P3FixedBitString >> bitAt: index [
	(index between: 1 and: size)
		ifFalse: [ 
			SubscriptOutOfBounds
				signalFor: index
				lowerBound: 1
				upperBound: size
				in: self ].
	^ super bitAt: index
]

{ #category : 'accessing' }
P3FixedBitString >> bitAt: index put: value [
	(index between: 1 and: size)
		ifFalse: [ 
			SubscriptOutOfBounds
				signalFor: index
				lowerBound: 1
				upperBound: size
				in: self ].
	^ super bitAt: index put: value
]

{ #category : 'comparing' }
P3FixedBitString >> hash [
	^ (super hash + size hash) hashMultiply
]

{ #category : 'initialization' }
P3FixedBitString >> initialize [
	super initialize.
	size := 1
]

{ #category : 'accessing' }
P3FixedBitString >> size [
	^ size
]

{ #category : 'private' }
P3FixedBitString >> size: numberOfBits [
	size := numberOfBits 
]
