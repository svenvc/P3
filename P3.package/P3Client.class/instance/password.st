accessing
password
	"Return the password  of my database connection.
	For no password, nil is used."

	^ properties at: #password ifAbsent: [ nil ]