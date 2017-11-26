accessing
user
	"Return the user of my database connection.
	For the default, nil is used."

	^ properties at: #user ifAbsent: [ nil ]