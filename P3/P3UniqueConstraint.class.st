Class {
	#name : #P3UniqueConstraint,
	#superclass : #P3Constraint,
	#category : #'P3-Support'
}

{ #category : #accessing }
P3UniqueConstraint class >> handlesType: type [
	^ type = 'UNIQUE'
]

{ #category : #accessing }
P3UniqueConstraint >> constraintType [
	^ 'UNIQUE'
]

{ #category : #accessing }
P3UniqueConstraint >> sqlDescription [
	^ String streamContents: [ :out |
		out nextPutAll: 'UNIQUE'.
		self constraintColumns isEmptyOrNil ifFalse: [
			out 
				nextPutAll: ' ('; 
				nextPutAll: ($, join: self constraintColumns); 
				nextPut: $) ] ]
]
