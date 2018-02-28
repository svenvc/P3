testing
isConnected
	"Return true when my connection is in working order (from my end)"

	^ connection notNil and: [ 
			connection isConnected and: [ 
				session notNil 
			] 
		]