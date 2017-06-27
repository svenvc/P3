initialization
readFrom: readStream
	| length |
	self tag: readStream next asCharacter.
	length := (self uint32From: readStream) - 4.
	self initializeForSize: length.
	readStream next: self size into: self rawByteBuffer