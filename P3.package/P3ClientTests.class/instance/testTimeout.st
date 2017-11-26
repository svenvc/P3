testing
testTimeout
	"Reconnect with an explicit timeout"
	client close.
	client url: url.
	client timeout: 1. "second"
	self assert: client isWorking.
	"The following (sleeping for 0.5 seconds) should just pass successfully"
	client execute: 'SELECT pg_sleep(0.5)'.
	"While the following (sleeping for 1.5 seconds) should time out"
	self should: [ client execute: 'SELECT pg_sleep(1.5)' ] raise: ConnectionTimedOut 