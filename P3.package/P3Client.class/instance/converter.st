accessing
converter
	^ converter ifNil: [ converter := P3Converter new ]