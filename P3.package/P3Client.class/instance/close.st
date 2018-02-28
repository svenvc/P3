initialize-release
close
	"Cleanly close my connection with the server"

	connection
		ifNotNil: [ 
			[ 
				self writeMessage: #[] tag: $X. 
				connection close ] on: Error do: [  ].
				self clearSession.
			connection := nil ]