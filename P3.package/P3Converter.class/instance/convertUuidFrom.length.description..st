converting
convertUuidFrom: bytes length: length description: description
	
	^ UUID nilUUID readFrom: (self asciiStreamFor: bytes length: length)