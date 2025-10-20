Extension { #name : 'SequenceableCollection' }

{ #category : '*P3' }
SequenceableCollection >> p3PrintUsing: delegate on: aStream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printValuesArray: self on: aStream
]
