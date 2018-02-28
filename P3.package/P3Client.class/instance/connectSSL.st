public
connectSSL
	"Connect me to a PostgreSQL database over an encrypted SSL connection. 
	Run the authentication and startup protocols. Configure the session."
	
	self 
		ensureOpen;
	 	writeMessage: self sslRequestMessage;
	 	upgradeToSSL;
		connect;
	 	setSSL
