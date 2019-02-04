"
I am P3ParameterDescription.

I am used to support the extended query protocol.
In particular, after the prepare/parse phase, my instances describe the type of each binding parameter.
"
Class {
	#name : #P3ParameterDescription,
	#superclass : #Object,
	#instVars : [
		'typeOid'
	],
	#category : #'P3-Support'
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
