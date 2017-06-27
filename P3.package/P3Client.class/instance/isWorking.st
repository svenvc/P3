testing
isWorking
	"Do a trivial query to confirm that I can interact with the server.
	Return true if successful"
	
	| n result |
	n := 999 atRandom.
	result := self query: ('SELECT {1} AS N' format: { n }).
	^ result first = 'SELECT 1' and: [ result third first first = n ]