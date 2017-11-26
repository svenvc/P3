accessing
timeout
	"Return the timeout in seconds I (want to) use, the default being 10 seconds."
	
	^ properties at: #timeout ifAbsentPut: [ 10 ]