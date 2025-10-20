Class {
	#name : 'P3PrimaryKeyConstraint',
	#superclass : 'P3Constraint',
	#category : 'P3-Support',
	#package : 'P3',
	#tag : 'Support'
}

{ #category : 'accessing' }
P3PrimaryKeyConstraint class >> handlesType: type [
	^ type = 'PRIMARY KEY'
]

{ #category : 'accessing' }
P3PrimaryKeyConstraint >> constraintType [
	^ 'PRIMARY KEY'
]

{ #category : 'accessing' }
P3PrimaryKeyConstraint >> sqlDescription [
	^ String streamContents: [ :out |
		out nextPutAll: 'PRIMARY KEY'.
		self constraintColumns isEmptyOrNil ifFalse: [
			out 
				nextPutAll: ' ('; 
				nextPutAll: ($, join: self constraintColumns); 
				nextPut: $) ] ]
]
