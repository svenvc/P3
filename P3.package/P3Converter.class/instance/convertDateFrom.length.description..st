converting
convertDateFrom: bytes length: length description: description
	^ Date readFrom: (self asciiStreamFor: bytes length: length)