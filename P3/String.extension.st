Extension { #name : #String }

{ #category : #'*P3' }
String >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintOn:using:"

	delegate printString: self on: stream
]

{ #category : #'*P3' }
String >> printAsP3TextOn: aStream [
	"Append to the argument aStream a representation of the receiver in 
	Postgres text format"

	aStream nextPutAll: self
]
