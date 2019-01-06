Extension { #name : #ScaledDecimal }

{ #category : #'*P3' }
ScaledDecimal >> printAsP3TextOn: aStream [
	"Append to the argument aStream a representation of the receiver in 
	Postgres text format"

	self printOn: aStream showingDecimalPlaces: scale
]
