testing
isSSL
	"Return true if my current connection is SSL encrypted"
	
	^ (properties at: 'ssl' ifAbsent: [ 'false' ]) = 'true'