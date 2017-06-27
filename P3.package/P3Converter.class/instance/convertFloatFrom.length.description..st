converting
convertFloatFrom: bytes length: length description: description
	^ Float readFrom: (self asciiStreamFor: bytes length: length)