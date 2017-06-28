login
logout
	connection ifNotNil: [ 
		connection close.
		connection := nil ]