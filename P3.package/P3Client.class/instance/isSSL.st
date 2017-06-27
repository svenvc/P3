testing
isSSL
	^ (properties at: 'ssl' ifAbsent: [ 'false' ]) = 'true'