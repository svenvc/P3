public
connect
	"Connect me to a PostgreSQL database. 
	Run the authentication and startup protocols. Configure the session."
	
	self 
		ensureOpen;
		writeMessage: self startupMessage;
		reset;
		runAuthentication;
		runStartup;
		initializeConverter;
	 	clearSSL