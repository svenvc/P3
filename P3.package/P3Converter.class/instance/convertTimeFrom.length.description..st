converting
convertTimeFrom: bytes length: length description: description
	^ Time readFrom: (self asciiStreamFor: bytes length: length)