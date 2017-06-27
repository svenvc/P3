accessing
encoder
	^ encoder ifNil: [ encoder := ZnCharacterEncoder utf8 ]