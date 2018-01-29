printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	stream print: self encoder identifier.
	stream space.
	self timezone ifNotNil: [ :tmz | stream print: tmz id ].
	stream nextPut: $)