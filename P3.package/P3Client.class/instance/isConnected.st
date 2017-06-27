testing
isConnected
	^ connection notNil 
		and: [ connection isConnected 
			and: [ (properties at: 'connected' ifAbsent: [ 'false' ]) = 'true' ] ]