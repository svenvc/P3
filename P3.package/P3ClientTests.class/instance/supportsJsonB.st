versionInfo
supportsJsonB

	| record version |
	
	record := (client query: 'SHOW server_version') firstRecord.
	version := ($. split: record first) collect: [ :part | part asNumber ].
	
	^ version first > 9 or: [ 
		version first = 9 and: [ version second > 4 ]		
	]