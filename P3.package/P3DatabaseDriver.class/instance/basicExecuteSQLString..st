executing
basicExecuteSQLString: aString
	| result |
	result := connection query: aString.
	self updateRowCountFrom: result first.
	^ (result third ifNil: [ #() ]) readStream