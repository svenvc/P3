Extension { #name : #ScaledDecimal }

{ #category : #'*P3' }
ScaledDecimal >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintOn:using:"

	delegate printScaledDecimal: self on: stream
]
