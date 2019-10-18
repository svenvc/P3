Extension { #name : #Date }

{ #category : #'*P3' }
Date >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintOn:using:"

	delegate printDate: self on: stream
]
