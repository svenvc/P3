private messages
startupMessage
	^ ByteArray streamContents: [ :out |
			out nextPutAll: #[ 0 3 0 0 ]. "Protocol major.minor 3.0"
			out nextPutAll: (self asCString: 'user').
			out nextPutAll: (self asCString: self user).
			self database ifNotNil: [ 
				out nextPutAll: (self asCString: 'database').
				out nextPutAll: (self asCString: self database) ].
			out nextPut: 0 ]