"
I am P3LineSegment

	[(x1,y1),(x2,y2)]

I am a P3GeometricObject

My internal reperesentation is a start and stop point
"
Class {
	#name : #P3LineSegment,
	#superclass : #P3GeometricObject,
	#instVars : [
		'start',
		'stop'
	],
	#category : #P3
}

{ #category : #'instance creation' }
P3LineSegment class >> readFrom: stream [
	| start stop |
	(stream peekFor: $[) ifFalse: [ self error: 'opening [ not found' ].
	start := P3Point readFrom: stream.
	(stream peekFor: $,) ifFalse: [ self error: 'separator , not found' ].
	stop := P3Point readFrom: stream.
	(stream peekFor: $]) ifFalse: [ self error: 'closing ] not found' ].
	^ self start: start stop: stop
]

{ #category : #'instance creation' }
P3LineSegment class >> start: start stop: stop [
	^ self new
		start: start;
		stop: stop;
		yourself
]

{ #category : #accessing }
P3LineSegment class >> tag [
	^ #lseg
]

{ #category : #'instance creation' }
P3LineSegment class >> xAxisUnit [
	^ self start: P3Point zero stop: (P3Point x: 1 y: 0) 
]

{ #category : #'instance creation' }
P3LineSegment class >> yAxisUnit [
	^ self start: P3Point zero stop: (P3Point x: 0 y: 1) 
]

{ #category : #comparing }
P3LineSegment >> = anotherLineSegment [
	self == anotherLineSegment ifTrue: [ ^ true ].
	self class = anotherLineSegment class ifFalse: [ ^ false ].
	^ start = anotherLineSegment start and: [ stop = anotherLineSegment stop ]
]

{ #category : #comparing }
P3LineSegment >> hash [
	^ (start hash + stop hash) hashMultiply
]

{ #category : #accessing }
P3LineSegment >> length [
	^ ((stop x - start x) squared + (stop y - start y) squared) sqrt
]

{ #category : #printing }
P3LineSegment >> printOn: stream [
	stream nextPut: $[.
	start printOn: stream.
	stream nextPut: $,.
	stop printOn: stream.
	stream nextPut: $]
]

{ #category : #accessing }
P3LineSegment >> start [
	^ start
]

{ #category : #private }
P3LineSegment >> start: point [
	start := point
]

{ #category : #accessing }
P3LineSegment >> stop [
	^ stop
]

{ #category : #private }
P3LineSegment >> stop: point [
	stop := point
]
