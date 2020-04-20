"
I am P3Line

	{a,b,c} ax+by+c=0

I am a P3GeometricObject

My internal representation consists of my 3 coefficients, a, b and c
"
Class {
	#name : #P3Line,
	#superclass : #P3GeometricObject,
	#instVars : [
		'a',
		'b',
		'c'
	],
	#category : #'P3-Objects'
}

{ #category : #'instance creation' }
P3Line class >> a: a b: b c: c [
	^ self new
		a: a;
		b: b;
		c: c;
		yourself
]

{ #category : #'instance creation' }
P3Line class >> readFrom: stream [
	| a b c |
	(stream peekFor: ${) ifFalse: [ 
		(P3Error parsingFailed: 'opening { not found') signal ].
	a := Number readFrom: stream.
	(stream peekFor: $,) ifFalse: [ 
		(P3Error parsingFailed: 'separator , not found') signal ].
	b := Number readFrom: stream.
	(stream peekFor: $,) ifFalse: [ 
		(P3Error parsingFailed: 'separator , not found') signal ].
	c := Number readFrom: stream.
	(stream peekFor: $}) ifFalse: [ 
		(P3Error parsingFailed: 'closing } not found') signal ].
	^ self a: a b: b c: c
]

{ #category : #accessing }
P3Line class >> tag [
	^ #line
]

{ #category : #'instance creation' }
P3Line class >> xAxis [
	^ self a: 0 b: 1 c: 0
]

{ #category : #'instance creation' }
P3Line class >> yAxis [
	^ self a: 1 b: 0 c: 0
]

{ #category : #comparing }
P3Line >> = anotherLine [
	self == anotherLine ifTrue: [ ^ true ].
	self class = anotherLine class ifFalse: [ ^ false ].
	^ a = anotherLine a and: [ b = anotherLine b and: [ c = anotherLine c ] ]
]

{ #category : #accessing }
P3Line >> a [
	^ a
]

{ #category : #private }
P3Line >> a: number [
	a := number
]

{ #category : #accessing }
P3Line >> b [
	^ b
]

{ #category : #private }
P3Line >> b: number [
	b := number
]

{ #category : #accessing }
P3Line >> c [
	^ c
]

{ #category : #private }
P3Line >> c: number [
	c := number
]

{ #category : #comparing }
P3Line >> hash [ 
	^ ((a hash + b hash) hashMultiply + c hash) hashMultiply 
]

{ #category : #comparing }
P3Line >> printOn: stream [
	stream 
		nextPut: ${;
		print: a;
		nextPut: $,;
		print: b;
		nextPut: $,;
		print: c;
		nextPut: $}
]
