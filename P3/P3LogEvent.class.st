"
I am P3LogEvent.
I am an Announcement.

Instances of my subclasses are sent to my announcer while P3Client executes.
This constitutes an object based logging mechanism.

My print representation is a single line in a textual log.

I hold the following information:

- a timestamp <DateAndTime> when the event was created
- a unique ID <Integer> within this image lifetime
- a PostgreSQL session identifier <Integer> (backend process id) that represents a connection
"
Class {
	#name : #P3LogEvent,
	#superclass : #Announcement,
	#instVars : [
		'timestamp',
		'id',
		'session'
	],
	#classVars : [
		'IdCounter',
		'LogEventAnnouncer'
	],
	#category : #'P3-Logging'
}

{ #category : #accessing }
P3LogEvent class >> announcer [
	"Return my Announcer, the object that I send my log events to"
	
	^ LogEventAnnouncer ifNil: [ LogEventAnnouncer := Announcer new ]
]

{ #category : #initialization }
P3LogEvent class >> initialize [
	IdCounter := 0.
	self environment 
		at: #SessionManager 
		ifPresent: [ :manager | manager default registerNetworkClassNamed: self name ]
		ifAbsent: [ Smalltalk addToStartUpList: self ]
]

{ #category : #convenience }
P3LogEvent class >> logToTranscript [
	"Arrange for a textual representation of the log events sent to my announcer to be printed on the Transcript"
	
	self stopLoggingToTranscript.
	^ self announcer 
		when: self 
		do: [ :event | event crLog ]
]

{ #category : #accessing }
P3LogEvent class >> nextId [
	"This should be thread safe because SmallInteger 
	arithmetic primitives cannot be interrupted"
	
	^ IdCounter := IdCounter + 1
]

{ #category : #convenience }
P3LogEvent class >> open [
	"Open an inspector on my announcer, which should offer a UI to see log events"
	
	^ self announcer inspect
]

{ #category : #'system startup' }
P3LogEvent class >> startUp [
	"Reset the id counter"
	
	IdCounter := 0
]

{ #category : #convenience }
P3LogEvent class >> stopLoggingToTranscript [
	"Stop sending a textual representation of my log events to the Transcript (see #logToTranscript)"

	self announcer unsubscribe: self
]

{ #category : #accessing }
P3LogEvent >> announcer [
	^ self class announcer
]

{ #category : #actions }
P3LogEvent >> emit [
	self announcer announce: self
]

{ #category : #accessing }
P3LogEvent >> id [
	^ id
]

{ #category : #initialization }
P3LogEvent >> initialize [
	super initialize.
	timestamp := DateAndTime now.
	id := self nextId
]

{ #category : #accessing }
P3LogEvent >> nextId [
	^ self class nextId
]

{ #category : #printing }
P3LogEvent >> printContentsOn: stream [
	"Subclasses should implement this to add output"
	
	self subclassResponsibility 
]

{ #category : #printing }
P3LogEvent >> printOn: stream [
	timestamp printYMDOn: stream.
	stream space.
	timestamp printHMSOn: stream. 
	stream space.
	id \\ 1000 printOn: stream base: 10 length: 3 padded: true.
	stream nextPutAll: ' [P3] '; print: session; space.
	self printContentsOn: stream
]

{ #category : #accessing }
P3LogEvent >> session [
	^ session
]

{ #category : #initialization }
P3LogEvent >> session: anObject [
	session := anObject
]

{ #category : #accessing }
P3LogEvent >> timestamp [
	^ timestamp
]
