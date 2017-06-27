private
ensureConnected
	self isConnected
		ifFalse: [ 
			self isSSL
				ifTrue: [ self connectSSL ]
				ifFalse: [ self connect ] ]