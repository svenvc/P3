converting
convertScaledDecimalFrom: bytes length: length description: description
	^ ScaledDecimal readFrom: (self asciiStreamFor: bytes length: length)