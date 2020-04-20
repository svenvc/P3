"
I am P3Path

	[(x1,y1), ... ,(xn,yn)] open
	((x1,y1), ... ,(xn,yn)) closed

I am a P3Polygon and a P3GeometricObject

I inherit my representation and add the option to be open instead of closed

"
Class {
	#name : #P3Path,
	#superclass : #P3Polygon,
	#instVars : [
		'open'
	],
	#category : #'P3-Objects'
}

{ #category : #'instance creation' }
P3Path class >> openPoints: collectionOfPoints [
	^ (self points: collectionOfPoints)
		beOpen;
		yourself
]

{ #category : #'instance creation' }
P3Path class >> readFrom: stream [
	| points closer path |
	points := OrderedCollection new.
	closer := nil.
	stream peek = $( ifTrue: [ closer := $) ].
	stream peek = $[ ifTrue: [ closer := $] ].
	closer 
		ifNil: [ (P3Error parsingFailed: 'opening ( or [ not found') signal ] 
		ifNotNil: [ stream next ]. 
	[ stream atEnd or: [ stream peek = closer ] ] whileFalse: [ | point |
		point := P3Point readFrom: stream.
		points add: point.
		(stream atEnd or: [ stream peek = closer ] ) 
			ifFalse: [ 
				(stream peekFor: $,) ifFalse: [ 
					(P3Error parsingFailed: 'separating , not found') signal ] ] ].
	(stream peekFor: closer) ifFalse: [ 
		(P3Error parsingFailed: 'closing ) or ] not found') signal ].	
	path := self points: points.
	closer = $] ifTrue: [ path beOpen ].
	^ path
]

{ #category : #accessing }
P3Path class >> tag [
	^ #path
]

{ #category : #comparing }
P3Path >> = anotherPath [
	^ super = anotherPath and: [ open = anotherPath isOpen ]
]

{ #category : #initialization }
P3Path >> beOpen [
	open := true
]

{ #category : #comparing }
P3Path >> hash [
	^ super hash xor: open hash
]

{ #category : #initialization }
P3Path >> initialize [
	super initialize.
	open := false
]

{ #category : #testing }
P3Path >> isClosed [
	^ open not
]

{ #category : #testing }
P3Path >> isOpen [
	^ open
]

{ #category : #printing }
P3Path >> printOn: stream [
	stream nextPut: (self isOpen ifTrue: [ $[ ] ifFalse: [ $( ]).
	self printPointsOn: stream.
	stream nextPut: (self isOpen ifTrue: [ $] ] ifFalse: [ $) ])	
	
]
