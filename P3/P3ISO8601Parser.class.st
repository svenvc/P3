"
I am P3ISO8601Parser.

I am a fast, non-validating ISO 8601 parser for Time, Date and DateAndTime objects.

I only accept the PostgreSQL ISO output format.

	YYYY-MM-DD hh:mm:ss.nnnnnnnnn[+|-]FF[.ff]

"
Class {
	#name : #P3ISO8601Parser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'timestampClass'
	],
	#category : #'P3-Support'
}

{ #category : #'instance creation' }
P3ISO8601Parser class >> on: stringOrReadStream [
	^ self new 
		on: stringOrReadStream readStream; 
		yourself
]

{ #category : #initialization }
P3ISO8601Parser >> initialize [
	timestampClass := DateAndTime
]

{ #category : #initialization }
P3ISO8601Parser >> on: readStream [
	stream := readStream 
]

{ #category : #parsing }
P3ISO8601Parser >> parseDate [
	| year month day |
	year := self parsePositiveInteger.
	month := day := 1.
	(stream peekFor: $-)
		ifTrue: [ 
			month := self parsePositiveInteger.
			(stream peekFor: $-)
				ifTrue: [ 
					day := self parsePositiveInteger ] ].
	^ Date year: year month: month day: day 
]

{ #category : #parsing }
P3ISO8601Parser >> parseDateAndTime [
	| date time timezoneOffset |
	date := self parseDateElements.
	stream peekFor: $ .
	time := self parseTimeElements.
	timezoneOffset := self parseOptionalTimezoneOffset.
	^ timestampClass 
			year: date first 
			month: date second 
			day: date third 
			hour: time first 
			minute: time second 
			second: time third 
			nanoSecond: time fourth 
			offset: timezoneOffset seconds  
]

{ #category : #parsing }
P3ISO8601Parser >> parseDateElements [
	| year month day |
	year := self parsePositiveInteger.
	month := day := 1.
	(stream peekFor: $-)
		ifTrue: [ 
			month := self parsePositiveInteger.
			(stream peekFor: $-)
				ifTrue: [ 
					day := self parsePositiveInteger ] ].
	^ Array with: year with: month with: day
]

{ #category : #parsing }
P3ISO8601Parser >> parseDecimalFraction [
	| integer power |
	integer := 0.
	power := 1.
	[ '0123456789' includes: stream peek ] 
		whileTrue: [ 
			integer := integer * 10 + stream next asciiValue - 48.
			power := power * 10 ].
	^ integer / power
]

{ #category : #parsing }
P3ISO8601Parser >> parseOptionalTimezoneOffset [
	^ ('+-' includes: stream peek)
			ifTrue: [ self parseTimezoneOffset ]
			ifFalse: [ 0 ]
]

{ #category : #parsing }
P3ISO8601Parser >> parsePositiveInteger [
	| integer |
	integer := 0.
	[ '0123456789' includes: stream peek ] 
		whileTrue: [ 
			integer := integer * 10 + stream next asciiValue - 48 ].
	^ integer
]

{ #category : #parsing }
P3ISO8601Parser >> parseTime [
	| hours minutes seconds nanoSeconds |
	hours := self parsePositiveInteger.
	minutes := seconds := nanoSeconds := 0.
	(stream peekFor: $:)
		ifTrue: [ 
			minutes := self parsePositiveInteger.
			(stream peekFor: $:)
				ifTrue: [ 
					seconds := self parsePositiveInteger.
					(stream peekFor: $.)
						ifTrue: [ 
							nanoSeconds := self parseDecimalFraction * 1e9 ] ] ].
	^ Time hour: hours minute: minutes second: seconds nanoSecond: nanoSeconds  
]

{ #category : #parsing }
P3ISO8601Parser >> parseTimeElements [
	| hours minutes seconds nanoSeconds |
	hours := self parsePositiveInteger.
	minutes := seconds := nanoSeconds := 0.
	(stream peekFor: $:)
		ifTrue: [ 
			minutes := self parsePositiveInteger.
			(stream peekFor: $:)
				ifTrue: [ 
					seconds := self parsePositiveInteger.
					(stream peekFor: $.)
						ifTrue: [ 
							nanoSeconds := self parseDecimalFraction * 1e9 ] ] ].
	^ Array with: hours with: minutes with: seconds with: nanoSeconds  
]

{ #category : #parsing }
P3ISO8601Parser >> parseTimezoneOffset [
	| sign hours minutes |
	sign := stream next = $- ifTrue: [ -1 ] ifFalse: [ 1 ].
	hours := self parsePositiveInteger.
	minutes := (stream peekFor: $:)
		ifTrue: [ self parsePositiveInteger ]
		ifFalse: [ 0 ].
	^ sign * ((hours * 3600) + (minutes * 60))
]

{ #category : #initialization }
P3ISO8601Parser >> timestampClass: aClass [
	"Set the class for timestamps, which will be sent #year:month:day:hour:minute:second:nanoSecond:offset:"
	
	timestampClass := aClass
]
