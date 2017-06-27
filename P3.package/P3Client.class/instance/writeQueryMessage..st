input/output
writeQueryMessage: queryString
	| encoder size |
	connection nextPut: $Q asInteger.
	encoder := self converter encoder.
	size := (encoder encodedByteCountForString: queryString) + 5.
	4 to: 1 by: -1 do: [ :index | connection nextPut: (size digitAt: index) ].
	queryString do: [ :each | encoder nextPut: each toStream: connection ].
	connection nextPut: 0.
	connection flush