"
I am P3RetryConnectionEvent.
I am a P3LogEvent.

I represent the fact that a PostgreSQL client connection failed and is being retried.
"
Class {
	#name : #P3RetryConnectionEvent,
	#superclass : #P3LogEvent,
	#instVars : [
		'remaining',
		'delay'
	],
	#category : #'P3-Logging'
}

{ #category : #accessing }
P3RetryConnectionEvent >> delay [
	^ delay
]

{ #category : #accessing }
P3RetryConnectionEvent >> delay: anObject [
	delay := anObject
]

{ #category : #printing }
P3RetryConnectionEvent >> printContentsOn: stream [
	stream print: #RetryConnection; space; print: remaining; nextPutAll: ' remaining, after '; print: delay; nextPut: $s
]

{ #category : #accessing }
P3RetryConnectionEvent >> remaining [
	^ remaining
]

{ #category : #accessing }
P3RetryConnectionEvent >> remaining: anObject [
	remaining := anObject
]
