Class {
	#name : #P3ParameterDescription,
	#superclass : #Object,
	#instVars : [
		'typeOid'
	],
	#category : #P3
}

{ #category : #printing }
P3ParameterDescription >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream << self typeName.
	stream nextPut: $)
]

{ #category : #accessing }
P3ParameterDescription >> typeName [
	^ (P3Converter typeMap at: self typeOid ifAbsent: [ ^ self typeOid ]) first
]

{ #category : #accessing }
P3ParameterDescription >> typeOid [
	^ typeOid
]

{ #category : #accessing }
P3ParameterDescription >> typeOid: anObject [
	typeOid := anObject
]
