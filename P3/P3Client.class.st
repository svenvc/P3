"
I am P3Client, a lean and mean PostgreSQL client.

PostgreSQL, often simply Postgres, is a free and open-source, ACID-compliant and transactional object-relational database management system (ORDBMS).

I use frontend/backend protocol 3.0 (PostgreSQL version 7.4 [2003] and later), implementing the simple query cycle. I support plaintext and md5 password authentication. When SQL queries return row data, I efficiently convert incoming data to objects. I support most common PostgreSQL types (P3Converter supportedTypes).

I can be configured manually or through a URL.

  P3Client new url: 'psql://username:password@localhost:5432/databasename'.

Not all properties need to be specified, the minimum is the following URL.

  P3Client new url: 'psql://user@localhost'.

I have a minimal public protocol, basically #query: (#execute: is an alias).

Opening a connection to the server (#open) and running the authentication and startup protocols (#connect) are done automatically when needed from #query.

I also support SSL connections. Use #connectSSL to initiate such a connection.

I represent a single database connection or session, I am not thread safe.


Examples 

Here is the simplest test that does an actual query, it should return true.

    (P3Client new url: 'psql://sven@localhost') in: [ :client |
        [ client isWorking ] ensure: [ client close ] ].

Here is how to create a simple table with some rows in it.

    (P3Client new url: 'psql://sven@localhost') in: [ :client |
        client execute: 'DROP TABLE IF EXISTS table1'.
        client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
        client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
        client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
        client close ].
	
Now we can query the contents of the simple table we just created.

    (P3Client new url: 'psql://sven@localhost') in: [ :client |
        [ client query: 'SELECT * FROM table1' ] ensure: [ client close ] ].

The result is an instance of P3Result

    a P3Result('SELECT 2' 2 records 3 colums)

P3Result contains 3 elements,  results, descriptions & data:
- Results is a string (collection of strings for multiple embedded queries) indicating successful execution.
- Descriptions is a collection of row field description objects.
- Data is a collection of rows with fully converted field values as objects.

The data itself is an array with 2 sub arrays, one for each record.

    #( #(1 'foo' true) #(2 'bar' false) )

Finally we can clean up.

    (P3Client new url: 'psql://sven@localhost') in: [ :client |
        [ client execute: 'DROP TABLE table1' ] ensure: [ client close ] ].


References 

-  https://postgresql.org
-  https://en.wikipedia.org/wiki/PostgreSQL
-  https://www.postgresql.org/docs/9.6/static/protocol.html


See also P3DatabaseDriver, an interface between Glorp, an advanced object-relational mapper, and me.

"
Class {
	#name : #P3Client,
	#superclass : #Object,
	#instVars : [
		'connection',
		'session',
		'settings',
		'properties',
		'converter',
		'message'
	],
	#category : 'P3'
}

{ #category : #accessing }
P3Client class >> url: anUrl [

	^ self new url: anUrl 
]

{ #category : #private }
P3Client >> asCString: string [
	| bytes |
	bytes := ByteArray new: string size + 1.
	"implicit cheap ASCII conversion"
	bytes replaceFrom: 1 to: string size with: string startingAt: 1. 
	"last byte is 0"
	^ bytes
]

{ #category : #private }
P3Client >> clearSSL [
	settings removeKey: #ssl ifAbsent: [ ]
]

{ #category : #private }
P3Client >> clearSession [

	session := nil
]

{ #category : #'private messages' }
P3Client >> clearTextPasswordMessage [
	self password ifNil: [ self error: 'Password required' ].
	^ self asCString: self password
]

{ #category : #'initialize-release' }
P3Client >> close [
	"Cleanly close my connection with the server"

	connection
		ifNotNil: [ 
			[ 
				self writeMessage: #[] tag: $X. 
				connection close ] on: Error do: [  ].
				self clearSession.
			connection := nil ]
]

{ #category : #public }
P3Client >> connect [
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
]

{ #category : #public }
P3Client >> connectSSL [
	"Connect me to a PostgreSQL database over an encrypted SSL connection. 
	Run the authentication and startup protocols. Configure the session."
	
	self 
		ensureOpen;
	 	writeMessage: self sslRequestMessage;
	 	upgradeToSSL;
		connect;
	 	setSSL

]

{ #category : #accessing }
P3Client >> connection [
	"Return the network connection I am using.
	When I am not connected, return nil."
	
	^ connection
]

{ #category : #accessing }
P3Client >> converter [
	"Return the converter that I am using.
	It holds the character encoding and timezone of the current database connection."
	
	^ converter ifNil: [ converter := P3Converter new ]
]

{ #category : #accessing }
P3Client >> converter: anObject [
	converter := anObject
]

{ #category : #accessing }
P3Client >> database [
	"Return the database name I (want to) connect to.
	For the default, nil is used."
	
	^ settings at: #database ifAbsent: [ nil ]
]

{ #category : #'initialize-release' }
P3Client >> database: string [
	"Set the name of the database to connect to.
	Set to nil or do not set to use the default."
	
	settings at: #database put: string
]

{ #category : #private }
P3Client >> ensureConnected [
	self isConnected
		ifFalse: [ 
			self isSSL
				ifTrue: [ self connectSSL ]
				ifFalse: [ self connect ] ]
]

{ #category : #private }
P3Client >> ensureOpen [
	connection ifNil: [ self open ]
]

{ #category : #'error handling' }
P3Client >> error: string [
	self signal: P3Error using: { $M -> string } asDictionary  
]

{ #category : #'error handling' }
P3Client >> errorNoticeInfo: payload [
	| info fieldType |
	info := Dictionary new.
	[ (fieldType := payload next) isZero ] 
		whileFalse: [ 
			info 
				at: fieldType asCharacter 
				put: (self converter asciiCStringFrom: payload) ].
	^ info
]

{ #category : #public }
P3Client >> execute: query [
	"Execute an SQL query against PostgreSQL, assuming no rows will be returned.
	Result is a string (collection of strings for multiple embedded queries) indicating successful execution.
	This is an alias for #query returning just the command result."
	
	| result |
	result := self query: query.
	^ result results
]

{ #category : #accessing }
P3Client >> host [
	"Return the host name I (want to) connect to.
	The default is localhost."

	^ settings at: #host ifAbsentPut: [ 'localhost' ]
]

{ #category : #'initialize-release' }
P3Client >> host: string [
	"Set the name of the host to connect to.
	If not set, defaults to localhost."
	
	settings at: #host put: string
]

{ #category : #'initialize-release' }
P3Client >> initialize [
	super initialize.
	
	settings := IdentityDictionary new.
	properties := Dictionary new.
]

{ #category : #private }
P3Client >> initializeConverter [

	self converter initializeFrom: properties
]

{ #category : #testing }
P3Client >> isConnected [
	"Return true when my connection is in working order (from my end)"

	^ connection notNil and: [ 
			connection isConnected and: [ 
				session notNil 
			] 
		]
]

{ #category : #testing }
P3Client >> isSSL [
	"Return true if my current connection is SSL encrypted"
	
	^ settings at: #ssl ifAbsent: [ false ]
]

{ #category : #testing }
P3Client >> isWorking [
	"Do a trivial query to confirm that I can interact with the server.
	Return true if successful"
	
	| n result |
	n := 999 atRandom.
	result := self query: ('SELECT {1} AS N' format: { n }).
	^ result result = 'SELECT 1' and: [ result firstFieldOfFirstRecord = n ]
]

{ #category : #'private messages' }
P3Client >> md5PasswordMessage: salt [
	"concat('md5', md5(concat(md5(concat(password, username)), random-salt))).
	Keep in mind the md5() function returns its result as a hex string."
	
	| credential salted |
	self password ifNil: [ self error: 'Password required' ].
	credential := (MD5 hashMessage: self password , self user) hex.
	salted := (MD5 hashMessage: credential , salt) hex.
	^ self asCString: 'md5' , salted
]

{ #category : #private }
P3Client >> newMessageBuilder [

	^ P3MessageBuilder newWithEncoder: self converter encoder
]

{ #category : #'initialize-release' }
P3Client >> open [
	"Open my connection with the server (do not yet #connect)"
	
	self close.
	connection := ZdcSocketStream openConnectionToHostNamed: self host port: self port.
	connection timeout: self timeout.
	message := P3MessageBuffer new

]

{ #category : #accessing }
P3Client >> password [
	"Return the password  of my database connection.
	For no password, nil is used."

	^ settings at: #password ifAbsent: [ nil ]
]

{ #category : #'initialize-release' }
P3Client >> password: string [
	"Set the password to use when connecting.
	Set to nil or don't set to use no password."

	settings at: #password put: string
]

{ #category : #accessing }
P3Client >> port [
	"Return the port I (want to) connect to.
	The default is 5432."

	^ settings at: #port ifAbsentPut: [ 5432 ]
]

{ #category : #'initialize-release' }
P3Client >> port: integer [
	"Set the port to connect to.
	If not set, defaults to 5432."
	
	settings at: #port put: integer
]

{ #category : #public }
P3Client >> prepare: query [
	"Create and return an instance of P3PreparedStatement by parsing query, 
	which can contain one or more placeholders, once. Later the prepared statement can be executed 
	multiple times by providing an array with a value for each placeholder. 
	When no longer needed, the prepared statement should be closed. See P3PreparedStatement."

	| queryName paramDescriptions rowDescriptions |
	
	queryName := query.

	self 
		ensureConnected;
		writeParseMessage: query name: queryName types: #();
		writeDescribeMessage: queryName type: $S;
		writeSyncMessage.

	self readMessage tag = $1
		ifFalse: [ ^ self error: 'ParseComplete message expecyted' ].

	self readMessage.
	message tag = $t
		ifTrue: [ paramDescriptions := self processParameterDescription: message readStream ]
		ifFalse: [ 
			paramDescriptions := #().
			message tag = $n 
				ifFalse: [ self error: 'NoData message expected' ] ].

	self readMessage.
	message tag = $T
		ifTrue: [ rowDescriptions := self processRowDescription: message readStream ]
		ifFalse: [ 
			rowDescriptions := #().
			message tag = $n
				ifFalse: [ self error: 'NoData message expected' ] ].

	self readMessage tag = $Z
		ifFalse: [ ^ self error: 'ReadyForQuery message expected' ].

	^ P3PreparedStatement newWith: self 
			name: queryName 
			parameters: paramDescriptions 
			fields: rowDescriptions
]

{ #category : #printing }
P3Client >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream print: self url.
	self session ifNotNil: [ stream space; print: session ].
	stream nextPut: $)
]

{ #category : #private }
P3Client >> processBackendKeyData: payload [

	session := payload uint32.
	properties at: 'backend_process_id' put: session.
	properties at: 'backend_secret_key' put: payload uint32
]

{ #category : #private }
P3Client >> processDataRowUsing: description [
	| count record readStream |
	readStream := message readStream.
	count := readStream uint16.
	record := Array new: count.
	1 to: count do: [ :index | | size |
		size := readStream uint32.
		size = 16rFFFFFFFF
			ifFalse: [ | object |
				object := (description at: index) convert: readStream length: size using: converter.
				record at: index put: object ] ].
	^ record
]

{ #category : #private }
P3Client >> processParameterDescription: payload [
	| count |
	count := payload uint16.
	^ Array new: count streamContents: [ :out |
			count timesRepeat: [ 
				out nextPut: (P3ParameterDescription new
					typeOid: payload int32;
					yourself) ] ]
]

{ #category : #private }
P3Client >> processParameterStatus: payload [
	"Do not yet use the converter since it is not yet initialized"
	
	| key value |
	
	key := self converter asciiCStringFrom: payload.
	value := self converter asciiCStringFrom: payload.
		
	properties at: key put: value
]

{ #category : #private }
P3Client >> processRowDescription: payload [
	| count |
	count := payload uint16.
	^ Array new: count streamContents: [ :out |
			count timesRepeat: [ 
				out nextPut: (P3RowFieldDescription new
					fieldName: (self converter encodedCStringFrom: payload);
					tableOid: payload uint32;
					attributeNumber: payload uint16;
					typeOid: payload uint32;
					typeSize: payload uint16;
					typeModifier: payload uint32;
					format: payload uint16;
					yourself) ] ]
]

{ #category : #public }
P3Client >> query: query [
	"Execute an SQL query against PostgreSQL. Return a triplet { result. descriptions. data }.
	Result is a string (collection of strings for multiple embedded queries) indicating successful execution.
	Descriptions is a collection of row field description objects.
	Data is a collection of rows with fully converted field values as objects."

	^ self 
		ensureConnected;
		writeQueryMessage: query;
		runQueryResult
]

{ #category : #accessing }
P3Client >> queryEncoding [
	"Return the name of the encoder used"
	
	^ self converter encoder identifier
]

{ #category : #'input/output' }
P3Client >> readMessage [
	"During normal operations, an error is reported followed by a ready for query so that we can continue to use the connection"
	
	^ self readMessageOnError: [ self assert: self readMessage tag = $Z ]
]

{ #category : #'input/output' }
P3Client >> readMessageCloseAfterError [
	"During authentication and startup errors result in the server closing the connection, do the same"
	
	^ self readMessageOnError: [ self close ]
]

{ #category : #'input/output' }
P3Client >> readMessageOnError: block [
	message readFrom: connection.
	message tag = $E 
		ifTrue: [ | info |
			info := self errorNoticeInfo: message readStream.
			block cull: info.
			self signal: P3Error using: info ].
	message tag = $N 
		ifTrue: [ | info |
			info := self errorNoticeInfo: message readStream.
			self signal: P3Notification using: info.
			^ self readMessage ].
	^ message
]

{ #category : #private }
P3Client >> reset [

	self clearSession.
	properties removeAll.
	converter := nil
]

{ #category : #protocol }
P3Client >> runAuthentication [
	[
	self readMessageCloseAfterError tag = $R
		ifTrue: [ | authenticationCode salt |
			authenticationCode := message readStream next: 4.
			authenticationCode = #[ 0 0 0 0 ] "AuthenticationOk"
				ifTrue: [ ^ self ].
			authenticationCode = #[ 0 0 0 3 ] "AuthenticationCleartextPassword"
				ifTrue: [ self writeMessage: self clearTextPasswordMessage tag: $p ].
			authenticationCode = #[ 0 0 0 5 ] "AuthenticationMD5Password"
				ifTrue: [
					salt := message readStream next: 4.
					self writeMessage: (self md5PasswordMessage: salt) tag: $p ] ]
		ifFalse: [ 
			^ self error: 'Unexpected message during authentication' ] ] repeat
]

{ #category : #protocol }
P3Client >> runExtendedQueryResult: descriptions [
	"Read DataRow ($D) messages until either a CommandComplete ($C) or PortalSuspended ($s) message is received."

	| rows |

			"Check for BindComplete message"
	message tag = $2
		ifFalse: [ ^ self error: 'BindComplete message expected' ].
	self readMessage.

	rows := Array streamContents: [ :out |
		[ 'Cs' includes: message tag ] whileFalse: [ 
			self assert: message tag = $D.
			out nextPut: (self processDataRowUsing: descriptions).
			self readMessage ] ].
	
	^ P3Result descriptions: descriptions
			rows: rows 
			message: (self converter asciiCStringFrom: message readStream)
]

{ #category : #protocol }
P3Client >> runExtendedQueryResults: fieldDescriptions [
	
	| results |

	self readMessage.
	results := Array streamContents: [ :out |
		[
			out nextPut: (self runExtendedQueryResult: fieldDescriptions).
			self readMessage tag = $Z ] whileFalse ].
	
	^ results
]

{ #category : #protocol }
P3Client >> runQueryResult [
	| result |
	result := P3Result new.
	self readMessage tag = $T
		ifTrue: [ result descriptions: (self processRowDescription: message readStream) ].
	message tag = $C ifFalse: [ 
		result data: (Array streamContents: [ :out |
			[ self readMessage tag = $C ] whileFalse: [ 
				self assert: message tag = $D.
				out nextPut: (self processDataRowUsing: result descriptions) ] ]) ].
	[
		result addResult: (self converter asciiCStringFrom: message readStream).
		self readMessage tag = $Z ] whileFalse.
	^ result
]

{ #category : #protocol }
P3Client >> runStartup [
	session := 999999 atRandom. "Sometimes $K is not sent and we need a nonNil session"
	[
	self readMessageCloseAfterError tag = $Z
		ifTrue: [ ^ self ].
	message tag = $S
		ifTrue: [ self processParameterStatus: message readStream ]
		ifFalse: [  
			message tag = $K
				ifTrue: [ self processBackendKeyData: message readStream ]
				ifFalse: [ ^ self error: 'Unexpected message during startup' ] ] ] repeat
]

{ #category : #accessing }
P3Client >> session [
	
	"Returns the current session identifier (backend process id) if connected"
	
	self isConnected ifFalse: [ session := nil ].
	
	^ session
]

{ #category : #private }
P3Client >> setConnected [

	settings at: #connected put: true
]

{ #category : #private }
P3Client >> setSSL [
	settings at: #ssl put: true
]

{ #category : #'error handling' }
P3Client >> signal: exceptionClass using: info [
	exceptionClass new 
		info: info; 
		messageText: (info at: $M);
		signal
]

{ #category : #'private messages' }
P3Client >> sslRequestMessage [
	^ #[4 210 22 47] "1234 5678"
]

{ #category : #'private messages' }
P3Client >> startupMessage [
	^ ByteArray streamContents: [ :out |
			out nextPutAll: #[ 0 3 0 0 ]. "Protocol major.minor 3.0"
			out nextPutAll: (self asCString: 'user').
			out nextPutAll: (self asCString: self user).
			self database ifNotNil: [ 
				out nextPutAll: (self asCString: 'database').
				out nextPutAll: (self asCString: self database) ].
			out nextPut: 0 ]
]

{ #category : #accessing }
P3Client >> timeout [
	"Return the timeout in seconds I (want to) use, the default being 10 seconds."
	
	^ settings at: #timeout ifAbsentPut: [ 10 ]
]

{ #category : #'initialize-release' }
P3Client >> timeout: seconds [

	settings at: #timeout put: seconds
]

{ #category : #protocol }
P3Client >> upgradeToSSL [
	| reply |
	reply := connection next asCharacter.
	reply = $S
		ifTrue: [ 
			connection := ZdcSecureSocketStream on: connection socket.
			connection connect ]
		ifFalse: [ 
			self error: 'PostgreSQL server did not honor SSL connection request' ]

]

{ #category : #accessing }
P3Client >> url [
	"Return my connection URL"
	
	^ ZnUrl new
		scheme: #psql;
		host: self host;
		port: self port;
		username: self user;
		password: self password;
		addPathSegments: (self database ifNotNil: [ { self database } ] ifNil: [ #() ]);
		yourself
]

{ #category : #'initialize-release' }
P3Client >> url: stringOrUrl [
	"Set my connection settings from stringOrUrl according to the format
	psql://username:password@localhost:5432/databasename 
	with the minimum being psql://user@localhost"
	
	| url |
	url := stringOrUrl asUrl.
	self assert: url scheme = #psql.
	self
		host: url host;
		port: (url portIfAbsent: [ 5432 ]);
		user: url username;
		password: url password;
		database: url firstPathSegment 
]

{ #category : #accessing }
P3Client >> user [
	"Return the user of my database connection.
	For the default, nil is used."

	^ settings at: #user ifAbsent: [ nil ]
]

{ #category : #'initialize-release' }
P3Client >> user: string [
	"Set the user to use when connecting.
	Set to nil or don't set to use the default."
	
	settings at: #user put: string
]

{ #category : #'input/output' }
P3Client >> writeDescribeMessage: aName type: aChar [
	"Type $S to describe a prepared statement; or $P to describe a portal."
	| msgBuilder |
	msgBuilder := self newMessageBuilder.
	msgBuilder
		nextPutByte: aChar asInteger;
		nextPutString: aName.
	self writeMessageNoFlush: msgBuilder asBytes tag: $D
]

{ #category : #'input/output' }
P3Client >> writeMessage: payload [
	| size |
	size := payload size + 4.
	4 to: 1 by: -1 do: [ :index | connection nextPut: (size digitAt: index) ].
	payload notEmpty 
		ifTrue: [ connection nextPutAll: payload ].
	connection flush
]

{ #category : #'input/output' }
P3Client >> writeMessage: payload tag: tag [
	connection nextPut: tag asInteger.
	self writeMessage: payload
]

{ #category : #'input/output' }
P3Client >> writeMessageNoFlush: payload [
	| size |
	size := payload size + 4.
	4 to: 1 by: -1 do: [ :index | connection nextPut: (size digitAt: index) ].
	connection nextPutAll: payload.

]

{ #category : #'input/output' }
P3Client >> writeMessageNoFlush: payload tag: tag [
	connection nextPut: tag asInteger.
	self writeMessageNoFlush: payload
]

{ #category : #'input/output' }
P3Client >> writeParseMessage: queryString name: statementName types: paramDataTypes [
	| msgBuilder |
	msgBuilder := self newMessageBuilder.
	msgBuilder
		nextPutString: statementName;
		nextPutString: queryString;
		nextPutInt16: paramDataTypes size.
	paramDataTypes do: [ :each | msgBuilder nextPutInt32: each ].
	self writeMessage: msgBuilder asBytes tag: $P 

	
]

{ #category : #'input/output' }
P3Client >> writeQueryMessage: queryString [
	| encoder size |
	connection nextPut: $Q asInteger.
	encoder := self converter encoder.
	size := (encoder encodedByteCountForString: queryString) + 5.
	4 to: 1 by: -1 do: [ :index | connection nextPut: (size digitAt: index) ].
	queryString do: [ :each | encoder nextPut: each toStream: connection ].
	connection nextPut: 0.
	connection flush
]

{ #category : #'input/output' }
P3Client >> writeSyncMessage [

	self writeMessage: #[] tag: $S. 

]
