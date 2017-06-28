accessing
firstResult
	^ results isString ifTrue: [ results ] ifFalse: [ results first ]