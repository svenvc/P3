accessing
session
	
	"Returns the current session identifier (backend process id) if connected"
	
	self isConnected ifFalse: [ session := nil ].
	
	^ session