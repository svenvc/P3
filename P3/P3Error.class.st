"
I am P3Error.

I get signalled when something goes wrong in using P3Client, either an error inside the driver itself, or an error signalled by the PostgreSQL database backend server.
"
Class {
	#name : #P3Error,
	#superclass : #Error,
	#instVars : [
		'info'
	],
	#category : #P3
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
