accessing
user
	"Return the user of my database connection.
	For the default, nil is used."

	^ settings at: #user ifAbsent: [ nil ]