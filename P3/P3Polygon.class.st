"
I am P3Polygon

	((x1,y1), ... ,(xn,yn))

I am a P3GeometricObject

My internal representation is an ordered collection of points
"
Class {
	#name : #P3Polygon,
	#superclass : #P3GeometricObject,
	#instVars : [
		'points'
	],
	#category : #'P3-Objects'
}

{ #category : #'instance creation' }
P3Polygon class >> points: aCollectionOfPoints [
	^ self new
		points: aCollectionOfPoints asOrderedCollection;
		yourself
]

{ #category : #'instance creation' }
P3Polygon class >> readFrom: stream [
	| points |
	points := OrderedCollection new.
	(stream peekFor: $() ifFalse: [ self error: 'opening ( not found' ].
	[ stream atEnd or: [ stream peek = $) ] ] whileFalse: [ | point |
		point := P3Point readFrom: stream.
		points add: point.
		(stream atEnd or: [ stream peek = $) ] ) 
			ifFalse: [ 
				(stream peekFor: $,) ifFalse: [ self error: 'separating , not found' ] ] ].
	(stream peekFor: $)) ifFalse: [ self error: 'closing ) not found' ].	
	^ self points: points
]

{ #category : #accessing }
P3Polygon class >> tag [
	^ #polygon
]

{ #category : #comparing }
P3Polygon >> = anotherPolygon [
	self == anotherPolygon ifTrue: [ ^ true ].
	self class = anotherPolygon class ifFalse: [ ^ false ].
	^ points = anotherPolygon points
]

{ #category : #comparing }
P3Polygon >> hash [
	^ points hash
]

{ #category : #testing }
P3Polygon >> isClosed [
	^ true
]

{ #category : #testing }
P3Polygon >> isOpen [
	^ false
]

{ #category : #accessing }
P3Polygon >> numberOfPoints [
	^ points size
]

{ #category : #accessing }
P3Polygon >> points [
	^ points
]

{ #category : #private }
P3Polygon >> points: collectionOfPoints [
	points := collectionOfPoints 
]

{ #category : #printing }
P3Polygon >> printOn: stream [
	stream nextPut: $(.
	self printPointsOn: stream.
	stream nextPut: $)
]

{ #category : #printing }
P3Polygon >> printPointsOn: stream [
	points 
		do: [ :each | each printOn: stream ] 
		separatedBy: [ stream nextPut: $, ]
]
