"
I am P3Error
"
Class {
	#name : #P3Error,
	#superclass : #Error,
	#instVars : [
		'info'
	],
	#category : 'P3'
}

{ #category : #accessing }
P3Error >> description [
	"Return a textual description of the exception."

	^ String streamContents: [ :stream | | mt |
		stream << self class name << ' PostgreSQL '.
		(mt := self messageText) isEmptyOrNil
			ifFalse: [ stream << mt ] ]
]

{ #category : #accessing }
P3Error >> info [
	^ info
]

{ #category : #accessing }
P3Error >> info: anObject [
	info := anObject
]
