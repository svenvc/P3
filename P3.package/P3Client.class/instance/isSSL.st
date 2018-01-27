testing
isSSL
	"Return true if my current connection is SSL encrypted"
	
	^ settings at: #ssl ifAbsent: [ false ]