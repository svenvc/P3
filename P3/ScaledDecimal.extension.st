Extension { #name : 'ScaledDecimal' }

{ #category : '*P3' }
ScaledDecimal >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printScaledDecimal: self on: stream
]
