printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	stream << fieldName.
	stream space.
	stream << self typeName.
	stream nextPut: $)