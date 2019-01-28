Extension { #name : #Object }

{ #category : #'*P3' }
Object >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	This is the default/fallback implementation.
	Check the implementors of #p3PrintOn:using:"
	
	delegate printObject: self on: stream
]
