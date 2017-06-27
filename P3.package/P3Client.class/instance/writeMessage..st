input/output
writeMessage: payload
	| size |
	size := payload size + 4.
	4 to: 1 by: -1 do: [ :index | connection nextPut: (size digitAt: index) ].
	connection nextPutAll: payload.
	connection flush