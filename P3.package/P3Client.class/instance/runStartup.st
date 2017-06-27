protocol
runStartup
	[
	self readMessageCloseAfterError tag = $Z
		ifTrue: [ ^ self ].
	message tag = $S
		ifTrue: [ self processParameterStatus: message readStream ]
		ifFalse: [  
			message tag = $K
				ifTrue: [ self processBackendKeyData: message readStream ]
				ifFalse: [ ^ self error: 'Unexpected message during startup' ] ] ] repeat