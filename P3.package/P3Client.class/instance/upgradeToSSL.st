protocol
upgradeToSSL
	| reply |
	reply := connection next asCharacter.
	reply = $S
		ifTrue: [ 
			connection := ZdcSecureSocketStream on: connection socket.
			connection connect ]
		ifFalse: [ 
			self error: 'PostgreSQL server did not honor SSL connection request' ]
