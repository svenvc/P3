"
I am P3Notification.

I get signalled when the PostgreSQL database backend server signals a notification, a kind of harmless warning.
"
Class {
	#name : 'P3Notification',
	#superclass : 'Notification',
	#instVars : [
		'info'
	],
	#category : 'P3-Core',
	#package : 'P3',
	#tag : 'Core'
}

{ #category : 'accessing' }
P3Notification >> code [
	"Return my unique, locale independent, 5 character string code."
	
	^ self info at: $C ifAbsent: [ nil ]
]

{ #category : 'accessing' }
P3Notification >> description [
	"Return a textual description of the exception."

	^ String streamContents: [ :stream |
		stream << self class name << ' PostgreSQL'.
		self messageText isEmptyOrNil
			ifFalse: [ stream space; << self messageText ] ]
]

{ #category : 'accessing' }
P3Notification >> info [
	^ info ifNil: [ info := Dictionary new ]
]

{ #category : 'accessing' }
P3Notification >> info: anObject [
	info := anObject
]

{ #category : 'accessing' }
P3Notification >> message [
	"Return my user oriented error message string.
	This could be locale dependent.
	My messageText gets initialized from this string"

	^ self info at: $M ifAbsent: [ '' ]
]

{ #category : 'accessing' }
P3Notification >> messageText [
	^ messageText ifNil: [ messageText := self message ]
]
