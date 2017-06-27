input/output
writeMessage: payload tag: tag
	connection nextPut: tag asInteger.
	self writeMessage: payload