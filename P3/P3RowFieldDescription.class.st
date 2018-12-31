"
I am P3RowFieldDescription

I hold meta data regarding the result of an SQL query. I describe one field/column in the result.

I know how to interpret and convert raw bytes with the help of a P3Converter (see #convert:length:using:) into objects.
"
Class {
	#name : #P3RowFieldDescription,
	#superclass : #Object,
	#instVars : [
		'fieldName',
		'tableOid',
		'attributeNumber',
		'typeOid',
		'typeSize',
		'typeModifier',
		'format'
	],
	#category : #P3
}

{ #category : #accessing }
P3RowFieldDescription >> attributeNumber [
	^ attributeNumber
]

{ #category : #accessing }
P3RowFieldDescription >> attributeNumber: anObject [
	attributeNumber := anObject
]

{ #category : #converting }
P3RowFieldDescription >> convert: bytes length: length using: converter [
	^ converter convert: bytes length: length description: self
]

{ #category : #accessing }
P3RowFieldDescription >> fieldName [
	^ fieldName
]

{ #category : #accessing }
P3RowFieldDescription >> fieldName: anObject [
	fieldName := anObject
]

{ #category : #accessing }
P3RowFieldDescription >> format [
	^ format
]

{ #category : #accessing }
P3RowFieldDescription >> format: anObject [
	format := anObject
]

{ #category : #printing }
P3RowFieldDescription >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream << fieldName.
	stream space.
	stream << self typeName.
	stream nextPut: $)
]

{ #category : #accessing }
P3RowFieldDescription >> tableOid [
	^ tableOid
]

{ #category : #accessing }
P3RowFieldDescription >> tableOid: anObject [
	tableOid := anObject
]

{ #category : #accessing }
P3RowFieldDescription >> typeModifier [
	^ typeModifier
]

{ #category : #accessing }
P3RowFieldDescription >> typeModifier: anObject [
	typeModifier := anObject
]

{ #category : #accessing }
P3RowFieldDescription >> typeName [
	^ (P3Converter typeMap at: self typeOid ifAbsent: [ ^ self typeOid ]) first
]

{ #category : #accessing }
P3RowFieldDescription >> typeOid [
	^ typeOid
]

{ #category : #accessing }
P3RowFieldDescription >> typeOid: anObject [
	typeOid := anObject
]

{ #category : #accessing }
P3RowFieldDescription >> typeSize [
	^ typeSize
]

{ #category : #accessing }
P3RowFieldDescription >> typeSize: anObject [
	typeSize := anObject
]
