testing
testNotification
	| raised |
	raised := false.
	[ client query: 'DROP TABLE IF EXISTS abcdef' ] 
		on: P3Notification 
		do: [ :notification | 
			raised := true.
			self assert: (notification description includesSubstring: 'abcdef').
			notification resume ].
	self assert: raised