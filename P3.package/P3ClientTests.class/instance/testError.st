testing
testError
	self should: [ client query: 'SELECT * FROM abcdef' ] raise: P3Error