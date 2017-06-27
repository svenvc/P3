printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	stream print: self url.
	self isConnected ifTrue: [ stream space; print: #connected ].
	stream nextPut: $)