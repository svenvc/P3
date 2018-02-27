printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	stream print: self url.
	self session ifNotNil: [ stream space; print: session ].
	stream nextPut: $)