testing
testConnection
	self assert: client isConnected.
	self assert: client isWorking.