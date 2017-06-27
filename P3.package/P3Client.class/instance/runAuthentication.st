protocol
runAuthentication
	[
	self readMessageCloseAfterError tag = $R
		ifTrue: [ | authenticationCode salt |
			authenticationCode := message readStream next: 4.
			authenticationCode = #[ 0 0 0 0 ] "AuthenticationOk"
				ifTrue: [ ^ self ].
			authenticationCode = #[ 0 0 0 3 ] "AuthenticationCleartextPassword"
				ifTrue: [ self writeMessage: self clearTextPasswordMessage tag: $p ].
			authenticationCode = #[ 0 0 0 5 ] "AuthenticationMD5Password"
				ifTrue: [
					salt := message readStream next: 4.
					self writeMessage: (self md5PasswordMessage: salt) tag: $p ] ]
		ifFalse: [ 
			^ self error: 'Unexpected message during authentication' ] ] repeat