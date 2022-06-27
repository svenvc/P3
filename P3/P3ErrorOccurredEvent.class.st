"
I am P3ErrorOccurredEvent.
I am a P3LogEvent.

I represent the occurrence of a P3Error or P3Notification.
"
Class {
	#name : #P3ErrorOccurredEvent,
	#superclass : #P3LogEvent,
	#instVars : [
		'exception'
	],
	#category : #'P3-Logging'
}

{ #category : #accessing }
P3ErrorOccurredEvent >> exception [
	^ exception
]

{ #category : #initialization }
P3ErrorOccurredEvent >> exception: anObject [
	exception := anObject
]

{ #category : #printing }
P3ErrorOccurredEvent >> printContentsOn: stream [
	stream print: #Error; space; nextPutAll: self exception description
]
