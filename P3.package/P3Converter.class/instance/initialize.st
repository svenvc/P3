initalize
initialize
	super initialize.
	asciiReadStream := String new readStream.
	asciiWriteStream := String new writeStream.
	stringWriteStream := String new writeStream.
	self initializeTypeMap