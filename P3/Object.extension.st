Extension { #name : #Object }

{ #category : #'*P3' }
Object >> printAsP3TextOn: aStream [
	"Append to the argument aStream a representation of the receiver in 
	Postgres text format"

	self printOn: aStream
]
