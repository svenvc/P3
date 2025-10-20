Extension { #name : 'UndefinedObject' }

{ #category : '*P3' }
UndefinedObject >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printNullOn: stream
]
