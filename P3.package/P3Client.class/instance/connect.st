public
connect
	"Connect me to a PostgreSQL database. 
	Run the authentication and startup protocols. Configure the session."
	
	self ensureOpen.
	self writeMessage: self startupMessage.
	self reset.
	self runAuthentication.
	self runStartup.
	self converter initializeFrom: properties.
	self setConnected.
	self clearSSL