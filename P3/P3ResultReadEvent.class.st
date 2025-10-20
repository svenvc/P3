"
I am P3ResultReadEvent.
I am a P3LogEvent.

I represent a P3Result of a previously sent SQL query (statement) received from PostgreSQL.

I hold the duration it took to execute the query and transfer the resulting data.

Note that I hold all data returned.
"
Class {
	#name : 'P3ResultReadEvent',
	#superclass : 'P3LogEvent',
	#instVars : [
		'result',
		'duration'
	],
	#category : 'P3-Logging',
	#package : 'P3',
	#tag : 'Logging'
}

{ #category : 'accessing' }
P3ResultReadEvent >> duration [
	^ duration
]

{ #category : 'initialization' }
P3ResultReadEvent >> duration: anObject [
	duration := anObject
]

{ #category : 'printing' }
P3ResultReadEvent >> printContentsOn: stream [
	stream print: #Result.
	stream space.
	self result printInfoOn: stream.
	stream nextPutAll: ', '; print: self duration; nextPutAll: ' ms'
]

{ #category : 'accessing' }
P3ResultReadEvent >> result [
	^ result
]

{ #category : 'initialization' }
P3ResultReadEvent >> result: anObject [
	result := anObject
]
