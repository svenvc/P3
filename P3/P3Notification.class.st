"
I am P3Notification.

I get signalled when the PostgreSQL database backend server signals a notification, a kind of harmless warning.
"
Class {
	#name : #P3Notification,
	#superclass : #Notification,
	#instVars : [
		'info'
	],
	#category : #'P3-Core'
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
