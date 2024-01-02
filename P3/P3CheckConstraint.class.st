"
I am P3CheckConstraint.
I am a P3Constraint.

I implement SQL CHECK.

I know my check clause.
"
Class {
	#name : #P3CheckConstraint,
	#superclass : #P3Constraint,
	#instVars : [
		'checkClause'
	],
	#category : #'P3-Support'
}

{ #category : #accessing }
P3CheckConstraint class >> handlesType: type [
	^ type = 'CHECK'
]

{ #category : #accessing }
P3CheckConstraint >> checkClause [
	^ checkClause
]

{ #category : #accessing }
P3CheckConstraint >> checkClause: anObject [
	checkClause := anObject
]

{ #category : #accessing }
P3CheckConstraint >> constraintType [
	^ 'CHECK'
]

{ #category : #accessing }
P3CheckConstraint >> loadDetailsUsing: client [
	| statement result |
	super loadDetailsUsing: client.
	statement := client format: 'SELECT check_clause FROM information_schema.check_constraints WHERE constraint_schema = $1 AND constraint_name = $2'.
	result := statement query: { self constraintSchema . self constraintName }.
	self checkClause: result firstFieldOfFirstRecord
]

{ #category : #accessing }
P3CheckConstraint >> sqlDescription [
	^ String streamContents: [ :out |
		out nextPutAll: 'CHECK'.
		self checkClause ifNotNil: [ :clause | 
			out space; nextPutAll: clause ] ]
]
