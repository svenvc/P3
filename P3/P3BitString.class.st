"
I am P3BitString.

Note that PSQL's B'100' is actually 2r001 in Pharo.

My internal representation is an Integer.

I am of the BIT VARYING type, with a flexible, as needed, length/size.
"
Class {
	#name : 'P3BitString',
	#superclass : 'Object',
	#instVars : [
		'bits'
	],
	#category : 'P3-Objects',
	#package : 'P3',
	#tag : 'Objects'
}

{ #category : 'instance creation' }
P3BitString class >> bits: integer [
	^ self new
		bits: integer;
		yourself
]

{ #category : 'instance creation' }
P3BitString class >> bits: integer count: count [
	^ self bits: integer
]

{ #category : 'instance creation' }
P3BitString class >> one [
	^ self bits: 1
]

{ #category : 'instance creation' }
P3BitString class >> readFrom: stream [
	| bits index |
	bits := 0.
	index := 1.
	[ stream atEnd or: [ ('01' includes: stream peek) not ] ] whileFalse: [ 
		bits := bits bitAt: index put: (stream next charCode - 48).
		index := index + 1 ].
	^ self bits: bits count: index - 1
]

{ #category : 'instance creation' }
P3BitString class >> zero [
	^ self new
]

{ #category : 'comparing' }
P3BitString >> = anotherBitString [
	self == anotherBitString ifTrue: [ ^ true ].
	self class = anotherBitString class ifFalse: [ ^ false ].
	^ bits = anotherBitString bits
]

{ #category : 'accessing' }
P3BitString >> bitAt: index [
	"One based index (PSQL is zero based), returns 0 or 1"
	
	^ bits bitAt: index
]

{ #category : 'accessing' }
P3BitString >> bitAt: index put: value [
	"One based index (PSQL is zero based), value must be 0 or 1"
	
	bits := bits bitAt: index put: value
]

{ #category : 'accessing' }
P3BitString >> bits [
	^ bits
]

{ #category : 'private' }
P3BitString >> bits: integer [
	bits := integer
]

{ #category : 'comparing' }
P3BitString >> hash [
	^ bits hash
]

{ #category : 'initialization' }
P3BitString >> initialize [
	super initialize.
	bits := 0
]

{ #category : 'printing' }
P3BitString >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printBitString: self on: stream
]

{ #category : 'printing' }
P3BitString >> printOn: stream [
	1 to: self size do: [ :index |
		stream nextPut: (48 + (bits bitAt: index)) asCharacter ]
]

{ #category : 'accessing' }
P3BitString >> size [
	^ bits = 0 ifTrue: [ 1 ] ifFalse: [ bits highBit ]
]
