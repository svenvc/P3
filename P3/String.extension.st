Extension { #name : 'String' }

{ #category : '*P3' }
String >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printString: self on: stream
]
