protocol
runStartup
	session := 999999 atRandom. "Sometimes $K is not sent and we need a nonNil session"
	[
	self readMessageCloseAfterError tag = $Z
		ifTrue: [ ^ self ].
	message tag = $S
		ifTrue: [ self processParameterStatus: message readStream ]
		ifFalse: [  
			message tag = $K
				ifTrue: [ self processBackendKeyData: message readStream ]
				ifFalse: [ ^ self error: 'Unexpected message during startup' ] ] ] repeat