private messages
clearTextPasswordMessage
	self password ifNil: [ self error: 'Password required' ].
	^ self asCString: self password