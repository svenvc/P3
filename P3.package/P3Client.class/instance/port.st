accessing
port
	"Return the port I (want to) connect to.
	The default is 5432."

	^ properties at: #port ifAbsentPut: [ 5432 ]