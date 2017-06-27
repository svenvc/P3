converting
convertIntegerFrom: bytes length: length description: description
	^ Integer readFrom: (self asciiStreamFor: bytes length: length) base: 10