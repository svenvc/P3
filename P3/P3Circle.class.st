"
I am P3Circle

	<(x,y),r>

I am a P3GeometricObject

My internal representation is a center point and a radius
"
Class {
	#name : #P3Circle,
	#superclass : #P3GeometricObject,
	#instVars : [
		'center',
		'radius'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3Circle class >> center: center radius: radius [
	^ self new
		center: center;
		radius: radius;
		yourself
]

{ #category : #'instance creation' }
P3Circle class >> readFrom: stream [
	| center radius |
	(stream peekFor: $<) ifFalse: [ self error: 'opening < not found' ].
	center := P3Point readFrom: stream.
	(stream peekFor: $,) ifFalse: [ self error: 'separating , not found' ].
	radius := Number readFrom: stream.
	(stream peekFor: $>) ifFalse: [ self error: 'closing > not found' ].
	^ self center: center radius: radius

]

{ #category : #accessing }
P3Circle class >> tag [
	^ #circle
]

{ #category : #'instance creation' }
P3Circle class >> unit [
	^ self center: P3Point origin radius: 1 
]

{ #category : #comparing }
P3Circle >> = anotherCircle [
	self == anotherCircle ifTrue: [ ^ true ].
	self class = anotherCircle class ifFalse: [ ^ false ].
	^ center = anotherCircle center and: [ radius = anotherCircle radius ]
]

{ #category : #accessing }
P3Circle >> area [
	^ Float pi * radius squared 
]

{ #category : #accessing }
P3Circle >> center [
	^ center
]

{ #category : #private }
P3Circle >> center: point [
	center := point
]

{ #category : #accessing }
P3Circle >> circumference [
	^ 2 * Float pi * radius
]

{ #category : #accessing }
P3Circle >> diameter [
	^ radius * 2
]

{ #category : #comparing }
P3Circle >> hash [
	^ (center hash hashMultiply + radius hash) hashMultiply
]

{ #category : #printing }
P3Circle >> printOn: stream [
	stream nextPut: $<.
	center printOn: stream.
	stream nextPut: $,.
	radius printOn: stream.
	stream nextPut: $>
]

{ #category : #accessing }
P3Circle >> radius [
	^ radius
]

{ #category : #private }
P3Circle >> radius: number [
	radius := number
]
