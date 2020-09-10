"
I am P3ConnectionClosedEvent.
I am a P3LogEvent.

I represent the closing of PostgreSQL client connection.
"
Class {
	#name : #P3ConnectionClosedEvent,
	#superclass : #P3LogEvent,
	#category : #'P3-Logging'
}

{ #category : #printing }
P3ConnectionClosedEvent >> printContentsOn: stream [	
	stream print: #Close
]
