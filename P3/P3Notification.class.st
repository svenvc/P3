"
I am P3Notification
"
Class {
	#name : #P3Notification,
	#superclass : #Notification,
	#instVars : [
		'info'
	],
	#category : 'P3'
}

{ #category : #accessing }
P3Notification >> description [
	"Return a textual description of the exception."

	^ String streamContents: [ :stream | | mt |
		stream << self class name << ' PostgreSQL '.
		(mt := self messageText) isEmptyOrNil
			ifFalse: [ stream << mt ] ]
]

{ #category : #accessing }
P3Notification >> info [
	^ info
]

{ #category : #accessing }
P3Notification >> info: anObject [
	info := anObject
]
