error handling
signal: exceptionClass using: info
	exceptionClass new 
		info: info; 
		messageText: (info at: $M);
		signal