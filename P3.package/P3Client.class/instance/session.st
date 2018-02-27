accessing
session

	self isConnected ifFalse: [ session := nil ].
	
	^ session