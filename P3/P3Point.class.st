"
I am P3Point

	(x,y)

I am a P3GeometricObject

My internal representation consists of my x and y coordinate
"
Class {
	#name : #P3Point,
	#superclass : #P3GeometricObject,
	#instVars : [
		'x',
		'y'
	],
	#category : #'P3-Objects'
}

{ #category : #'instance creation' }
P3Point class >> origin [
	^ self zero
]

{ #category : #'instance creation' }
P3Point class >> readFrom: stream [
	| x y |
	(stream peekFor: $() ifFalse: [ self error: 'opening ( not found' ].
	x := Number readFrom: stream.
	(stream peekFor: $,) ifFalse: [ self error: 'separator , not found' ].
	y := Number readFrom: stream.
	(stream peekFor: $)) ifFalse: [ self error: 'closing ) not found' ].
	^ self x: x y: y
]

{ #category : #accessing }
P3Point class >> tag [
	^ #point
]

{ #category : #'instance creation' }
P3Point class >> unit [
	^ self x: 1 y: 1
]

{ #category : #'instance creation' }
P3Point class >> x: x y: y [
	^ self new
		x: x;
		y: y;
		yourself
]

{ #category : #'instance creation' }
P3Point class >> zero [
	^ self x: 0 y: 0
]

{ #category : #comparing }
P3Point >> = anotherPoint [
	self == anotherPoint ifTrue: [ ^ true ].
	self class = anotherPoint class ifFalse: [ ^ false ].
	^ x = anotherPoint x and: [ y = anotherPoint y ]
]

{ #category : #comparing }
P3Point >> hash [
	^ ( x hash hashMultiply + y hash) hashMultiply
]

{ #category : #printing }
P3Point >> printOn: stream [
	stream nextPut: $(.
	x printOn: stream.
	stream nextPut: $,.
	y printOn: stream.
	stream nextPut: $)
]

{ #category : #accessing }
P3Point >> x [
	^ x
]

{ #category : #private }
P3Point >> x: number [
	x := number
]

{ #category : #accessing }
P3Point >> y [
	^ y
]

{ #category : #private }
P3Point >> y: number [
	y := number
]
