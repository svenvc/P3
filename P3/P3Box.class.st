"
I am P3Box

	(x1,y1),(x2,y2)

I am a P3GeometricObject

My internal representation is an upper right and lower left point
"
Class {
	#name : #P3Box,
	#superclass : #P3GeometricObject,
	#instVars : [
		'upperRight',
		'lowerLeft'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3Box class >> readFrom: stream [
	| upperRight lowerLeft |
	upperRight := P3Point readFrom: stream.
	(stream peekFor: $,) ifFalse: [ self error: 'separator , not found' ].
	lowerLeft := P3Point readFrom: stream.
	^ self upperRight: upperRight lowerLeft: lowerLeft
]

{ #category : #accessing }
P3Box class >> tag [
	^ #box
]

{ #category : #'instance creation' }
P3Box class >> unit [
	^ self upperRight: P3Point unit lowerLeft: P3Point zero
]

{ #category : #'instance creation' }
P3Box class >> upperRight: upperRight lowerLeft: lowerLeft [
	^ self new
		upperRight: upperRight;
		lowerLeft: lowerLeft;
		yourself
]

{ #category : #'instance creation' }
P3Box class >> zero [
	^ self upperRight: P3Point zero lowerLeft: P3Point zero
]

{ #category : #comparing }
P3Box >> = anotherBox [
	self == anotherBox ifTrue: [ ^ true ].
	self class = anotherBox class ifFalse: [ ^ false ].
	^ upperRight = anotherBox upperRight and: [ lowerLeft = anotherBox lowerLeft ]
]

{ #category : #accessing }
P3Box >> area [
	^ self width * self height
]

{ #category : #accessing }
P3Box >> center [
	^ P3Point x: (self width / 2 + lowerLeft x) y: (self height / 2 + lowerLeft y)
]

{ #category : #comparing }
P3Box >> hash [
	^ (upperRight hash + lowerLeft hash) hashMultiply
]

{ #category : #accessing }
P3Box >> height [
	^ upperRight y - lowerLeft y
]

{ #category : #accessing }
P3Box >> lowerLeft [
	^ lowerLeft 
]

{ #category : #private }
P3Box >> lowerLeft: point [
	lowerLeft := point
]

{ #category : #printing }
P3Box >> printOn: stream [
	upperRight printOn: stream.
	stream nextPut: $,.
	lowerLeft printOn: stream
]

{ #category : #accessing }
P3Box >> upperRight [
	^ upperRight
]

{ #category : #private }
P3Box >> upperRight: point [
	upperRight := point
]

{ #category : #accessing }
P3Box >> width [
	^ upperRight x - lowerLeft x
]
