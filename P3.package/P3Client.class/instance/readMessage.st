input/output
readMessage
	"During normal operations, an error is reported followed by a ready for query so that we can continue to use the connection"
	
	^ self readMessageOnError: [ self assert: self readMessage tag = $Z ]