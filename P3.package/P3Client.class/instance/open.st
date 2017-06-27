initialize-release
open
	self close.
	connection := ZdcSocketStream openConnectionToHostNamed: self host port: self port.
	message := P3MessageBuffer new
