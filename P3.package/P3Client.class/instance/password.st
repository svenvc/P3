accessing
password
	"Return the password  of my database connection.
	For no password, nil is used."

	^ settings at: #password ifAbsent: [ nil ]