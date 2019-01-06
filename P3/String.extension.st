Extension { #name : #String }

{ #category : #'*P3' }
String >> printAsP3TextOn: aStream [
	"Append to the argument aStream a representation of the receiver in 
	Postgres text format"

	aStream nextPutAll: self
]
