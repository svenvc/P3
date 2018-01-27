accessing
database
	"Return the database name I (want to) connect to.
	For the default, nil is used."
	
	^ settings at: #database ifAbsent: [ nil ]