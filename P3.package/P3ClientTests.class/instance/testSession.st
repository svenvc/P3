testing
testSession

	| session |
	
	session := client session. "from #setUp"
	
	self assert: client session isNotNil.
	
	client execute: 'SELECT NOW();'.
	
	self assert: session equals: client session.
	
	client close.
	
	self assert: client session isNil.
	
	client connect.
	
	self deny: session = client session.
	
	client clearSession.
	
	self 
		deny: client isConnected;
		assert: client session isNil.
		
	
	
	
	


