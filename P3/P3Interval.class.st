"
I am P3Interval, a time duration (INTERVAL).

I store all components separately.

I support the 'postgres' default IO format.

I can also print myself using the 'iso8601 with designators' format.

This is currently an MVP implementation.
"
Class {
	#name : 'P3Interval',
	#superclass : 'Object',
	#instVars : [
		'years',
		'months',
		'days',
		'hours',
		'minutes',
		'seconds'
	],
	#category : 'P3-Objects',
	#package : 'P3',
	#tag : 'Objects'
}

{ #category : 'private' }
P3Interval class >> readDesignator: stream [
	self skipSeparators: stream.
	^ String streamContents: [ :out |
		[ stream atEnd not and: [ stream peek isLetter or: [ stream peek = $: ] ] ] 
			whileTrue: [ out nextPut: stream next ] ]
]

{ #category : 'instance creation' }
P3Interval class >> readFrom: stream [
	| years months days hours minutes seconds number word helper count |
	years := months := days := hours := minutes := seconds := 0.
	helper := [ :value :designator |
		(designator beginsWith: 'year') ifTrue: [ years := value ].
		(designator beginsWith: 'mon') ifTrue: [ months := value ].
		(designator beginsWith: 'day') ifTrue: [ days := value ] ].
	count := number := 0.
	[ count <= 3 ] whileTrue: [
		self skipSeparators: stream.
		number := stream atEnd ifTrue: [ nil ] ifFalse: [ Number readFrom: stream ].
		word := self readDesignator: stream.
		word = ':' 
			ifTrue: [ count := 4 ]
			ifFalse: [ 
				helper value: number value: word.
		 		count := count + 1 ] ].
	stream atEnd 
		ifFalse: [ 
			hours := number.
			stream peekFor: $:.
			minutes := Number readFrom: stream.
			stream peekFor: $:.
			seconds := Number readFrom: stream ].
	^ self years: years months: months days: days hours: hours minutes: minutes seconds: seconds
]

{ #category : 'private' }
P3Interval class >> skipSeparators: stream [
	[ stream atEnd not and: [ stream peek isSeparator ] ] whileTrue: [ stream next ]
]

{ #category : 'instance creation' }
P3Interval class >> years: years months: months days: days hours: hours minutes: minutes seconds: seconds [
	^ self new
		years: years;
		months: months;
		days: days;
		hours: hours;
		minutes: minutes;
		seconds: seconds;
		yourself
]

{ #category : 'instance creation' }
P3Interval class >> zero [
	^ self new
]

{ #category : 'comparing' }
P3Interval >> = anotherInterval [
	self == anotherInterval
		ifTrue: [ ^ true ].
	self class = anotherInterval class
		ifFalse: [ ^ false ].
	^ years = anotherInterval years
		and: [ months = anotherInterval months
				and: [ days = anotherInterval days
						and: [ hours = anotherInterval hours
								and: [ minutes = anotherInterval minutes
										and: [ seconds = anotherInterval seconds ] ] ] ] ]
]

{ #category : 'accessing' }
P3Interval >> days [
	^ days
]

{ #category : 'accessing' }
P3Interval >> days: anObject [
	days := anObject
]

{ #category : 'comparing' }
P3Interval >> hash [
	^ ((years hash + months hash + days hash) hashMultiply
		+ (hours hash + minutes hash + seconds hash) hashMultiply)
		hashMultiply
]

{ #category : 'accessing' }
P3Interval >> hours [
	^ hours
]

{ #category : 'accessing' }
P3Interval >> hours: anObject [
	hours := anObject
]

{ #category : 'initialization' }
P3Interval >> initialize [
	super initialize.
	years := months := days := hours := minutes := seconds := 0
]

{ #category : 'accessing' }
P3Interval >> minutes [
	^ minutes
]

{ #category : 'accessing' }
P3Interval >> minutes: anObject [
	minutes := anObject
]

{ #category : 'accessing' }
P3Interval >> months [
	^ months
]

{ #category : 'accessing' }
P3Interval >> months: anObject [
	months := anObject
]

{ #category : 'printing' }
P3Interval >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printInterval: self on: stream
]

{ #category : 'printing' }
P3Interval >> printIso8601On: stream [
	stream nextPut: $P.
	years = 0 ifFalse: [ 
		stream print: years; nextPut: $Y ].
	months = 0 ifFalse: [
		stream print: months; nextPut: $M ].
	days = 0 ifFalse: [
		stream print: days; nextPut: $D ].
	stream nextPut: $T.
	hours = 0 ifFalse: [ 
		stream print: hours; nextPut: $H ].
	minutes = 0 ifFalse: [
		stream print: minutes; nextPut: $M ].
	seconds = 0 ifFalse: [
		stream print: seconds; nextPut: $S ]
]

{ #category : 'printing' }
P3Interval >> printOn: stream [
	| space |
	space := false.
	years = 0 ifFalse: [ 
		stream print: years; space.
		stream nextPutAll: (years = 1 ifTrue: [ 'year' ] ifFalse: [ 'years' ]).
		space := true ].
	months = 0 ifFalse: [
		space ifTrue: [ stream space ]. 
		stream print: months; space.
		stream nextPutAll: (months = 1 ifTrue: [ 'mon' ] ifFalse: [ 'mons' ]).
		space := true ].
	days = 0 ifFalse: [
		space ifTrue: [ stream space ]. 
		stream print: days; space.
		stream nextPutAll: (days = 1 ifTrue: [ 'day' ] ifFalse: [ 'days' ]).
		space := true ].
	space ifTrue: [ stream space ].
	hours printOn: stream base: 10 length: 2 padded: true.
	stream nextPut: $:.
	minutes printOn: stream base: 10 length: 2 padded: true.
	stream nextPut: $:.
	seconds < 10 ifTrue: [ stream print: 0 ].
	seconds printOn: stream
]

{ #category : 'accessing' }
P3Interval >> seconds [
	^ seconds
]

{ #category : 'accessing' }
P3Interval >> seconds: anObject [
	seconds := anObject
]

{ #category : 'accessing' }
P3Interval >> years [
	^ years
]

{ #category : 'accessing' }
P3Interval >> years: anObject [
	years := anObject
]
