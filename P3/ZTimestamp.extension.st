Extension { #name : 'ZTimestamp' }

{ #category : '*P3' }
ZTimestamp >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printDateAndTime: self on: stream
]

{ #category : '*P3' }
ZTimestamp >> translateTo: offset [
	"Polymorphic to DateAndTime>>#translateTo:"
	
	^ self - offset asDuration
]
