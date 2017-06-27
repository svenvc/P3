initialize-release
close
	connection
		ifNotNil: [ 
			[ 
				self writeMessage: #[] tag: $X. 
				connection close ] on: Error do: [  ].
			properties at: 'connected' put: 'false'.
			connection := nil ]