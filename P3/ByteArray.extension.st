Extension { #name : 'ByteArray' }

{ #category : '*P3' }
ByteArray >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printByteArray: self on: stream
]
