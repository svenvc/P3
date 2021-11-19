"
P3ISO8601ParserTest holds tests for P3ISO8601Parser
"
Class {
	#name : #P3ISO8601ParserTest,
	#superclass : #TestCase,
	#category : #'P3-Tests'
}

{ #category : #tests }
P3ISO8601ParserTest >> testDate [
	self 
		assert: (P3ISO8601Parser on: '2020-10-12') parseDate 
		equals: (Date year: 2020 month: 10 day: 12).
	self 
		assert: (P3ISO8601Parser on: '2020-02-29') parseDate 
		equals: (Date year: 2020 month: 02 day: 29).
	self 
		assert: (P3ISO8601Parser on: '2020-01-01') parseDate 
		equals: (Date year: 2020 month: 01 day: 01).
	self 
		assert: (P3ISO8601Parser on: '2020-12-31') parseDate 
		equals: (Date year: 2020 month: 12 day: 31).
]

{ #category : #tests }
P3ISO8601ParserTest >> testDateAndTime [
	self 
		assert: (P3ISO8601Parser on: '2020-10-13 10:49:48.251174+02') parseDateAndTime
		equals: (DateAndTime year: 2020 month: 10 day: 13 hour: 10 minute: 49 second: 48 nanoSecond: 251174000 offset: 2 hours).
	self 
		assert: (P3ISO8601Parser on: '2020-10-13 10:49:48.251174') parseDateAndTime
		equals: (DateAndTime year: 2020 month: 10 day: 13 hour: 10 minute: 49 second: 48 nanoSecond: 251174000 offset: Duration zero).

]

{ #category : #tests }
P3ISO8601ParserTest >> testTime [
	self 
		assert: (P3ISO8601Parser on: '07:08:09') parseTime
		equals: (Time hour: 7 minute: 8 second: 9).
	self 
		assert: (P3ISO8601Parser on: '01:02:03.000123') parseTime
		equals: (Time hour: 1 minute: 2 second: 3 nanoSecond: 123000).

]

{ #category : #tests }
P3ISO8601ParserTest >> testZTimestamp [
	self 
		assert: ((P3ISO8601Parser on: '2020-10-13 10:49:48.251174+02') timestampClass: ZTimestamp; parseDateAndTime)
		equals: (ZTimestamp year: 2020 month: 10 day: 13 hour: 10 minute: 49 second: 48 nanoSecond: 251174000 offset: 2 hours).
	self 
		assert: ((P3ISO8601Parser on: '2020-10-13 10:49:48.251174') timestampClass: ZTimestamp; parseDateAndTime)
		equals: (ZTimestamp year: 2020 month: 10 day: 13 hour: 10 minute: 49 second: 48 nanoSecond: 251174000 offset: Duration zero).

]
