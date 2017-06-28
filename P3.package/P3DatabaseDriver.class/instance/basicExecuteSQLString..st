executing
basicExecuteSQLString: aString
	| result |
	result := connection query: aString.
	rowCount := result totalRowCount.
	^ (result hasData ifTrue: [ result data ] ifFalse: [ #() ]) readStream