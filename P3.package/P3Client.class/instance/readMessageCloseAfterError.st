input/output
readMessageCloseAfterError
	"During authentication and startup errors result in the server closing the connection, do the same"
	
	^ self readMessageOnError: [ self close ]