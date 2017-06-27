initialize-release
open
	"Open my connection with the server (do not yet #connect)"
	
	self close.
	connection := ZdcSocketStream openConnectionToHostNamed: self host port: self port.
	message := P3MessageBuffer new
