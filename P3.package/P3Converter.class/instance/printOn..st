printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	stream print: self encoder identifier.
	stream space.
	stream print: self timezone id.
	stream nextPut: $)