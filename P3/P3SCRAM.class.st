"
I am P3SCRAM (Salted Challenge Response Authentication Mechanism for SASL (Simple Authentication and Security Layer) as well as GSS-API (Generic Security Service Application Program Interface).

https://en.wikipedia.org/wiki/Salted_Challenge_Response_Authentication_Mechanism
https://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer
https://en.wikipedia.org/wiki/Generic_Security_Services_Application_Program_Interface

https://tools.ietf.org/html/rfc5802
https://tools.ietf.org/html/rfc7677

SCRAM is a client-first protocol, I implement the client side.

0. setup

  scram := P3SCRAM sha256; user: 'user'; password: 'pencil'.

1. client -> server (send identification & random nounce)

  scram clientFirstMessage. ""n,,n=user,r=XXX1""

2. server -> client (receive challenge, extended random nounce, salt & iterations)

  scram serverFirstMessage: 'r=XXX1XXX,s=YYYY,i=NNNN'.

3. client -> server (send proof, server will verify)

  scram clientFinalMessage. ""c=biws,r=XXX1XXX,p=PPPP""

4. server -> client (receive success, client will verify)

	scram serverFinalMessage: 'v=VVVV'.

Performance note

The computation of the saltedPasssword takes a noticeable amount of time,
especially with SHA-256 and the conventional 4096 iterations.
For this reason this computation is cached.

Furthermore, to save time between usages, clients can store my instances
in my store, under a key, so they can reuse them, potentially gaining
speed by using a cached result. See P3SCRAM class>>#storeAt:ifAbsentPut:
This speedup is for all but the first execution of a particular authentication.

Security note

The information held in my instances is sensitive.
For this reason, my class side store will be reset before each image save.

About PostgreSQL's password storage 

If you execute 'SELECT rolname,rolpassword FROM pg_authid' with enough privileges,
you can see how PostgreSQL stores passwords. In the case of SCRAM-SHA-256, 
rolpassword seems to have the following format (using terms used in this implementation): 

SCRAM-SHA-256$<iterations>:<salt(base64>$<storedKey(base64>:<serverKey(base64)>

Using iterations and salt, and of course the password itself, constitutes 
enough information to calculate everything that does not depend on the nounces.
"
Class {
	#name : #P3SCRAM,
	#superclass : #Object,
	#instVars : [
		'user',
		'password',
		'salt',
		'hash',
		'hmac',
		'iteratedHash',
		'clientNounce',
		'serverNounce',
		'saltedPassword'
	],
	#classVars : [
		'Store'
	],
	#category : #'P3-Support'
}

{ #category : #'class initialization' }
P3SCRAM class >> initialize [
	self environment 
		at: #SessionManager 
		ifPresent: [ :manager | manager default registerNetworkClassNamed: self name ]
		ifAbsent: [ Smalltalk addToShutDownList: self ]
]

{ #category : #private }
P3SCRAM class >> parseMessage: string [
	"Expected format: [k=v],[k=v],... with empty (,,) and single elements (n=) being ignored"
	
	| info |
	info := Dictionary new.
	($, split: string) do: [ :attributeString | | index |
		index := attributeString indexOf: $=.
		(index between: 2 and: attributeString size - 1)
			ifTrue: [ | key value |
				key := attributeString first: index - 1.
				value := attributeString allButFirst: index.
				info at: key put: value ] ].
	^ info
]

{ #category : #'class initialization' }
P3SCRAM class >> reset [
	"Completely throw away my store. It contains sensitive information."
	
	Store := nil
]

{ #category : #'system startup' }
P3SCRAM class >> shutDown [
	"Prevent my store of sensitive information to be saved with an image"
	
	self reset
]

{ #category : #accessing }
P3SCRAM class >> store [
	"I maintain a store with instances registered under a key, using a TTLCache of 1 hour"
	
	^ Store ifNil: [ Store := TTLCache new timeToLive: 1 hour; yourself ]
]

{ #category : #accessing }
P3SCRAM class >> storeAt: key ifAbsentPut: block [
	"If my store holds a previously registered and used instance, return it,
	else evaluate block, which should return a newly created instance, that I store and return.
	Used instances cache their saltedPassword for improved performance for 1 hour."

	^ self store 
		at: key 
		ifAbsentPut: block
]

{ #category : #private }
P3SCRAM >> authMessage [
	^ self clientFirstMessageBare , ',' 
		, self serverFirstMessage , ',' 
		, self clientFinalMessageWithoutProof 
]

{ #category : #accessing }
P3SCRAM >> channelBinding [
	^ 'n,,'
]

{ #category : #private }
P3SCRAM >> clearSaltedPassword [
	saltedPassword := nil
]

{ #category : #public }
P3SCRAM >> clientFinalMessage [
	"This is the response message that the client sends to the server,
	answering a previously received serverFirstMessage with a proof"
	
	^ self clientFinalMessageWithoutProof 
		, ',p=' , self clientProof base64Encoded
]

{ #category : #private }
P3SCRAM >> clientFinalMessageWithoutProof [
	^ 'c=' , self channelBinding asByteArray base64Encoded 
		, ',r=' , self fullNounce 
]

{ #category : #public }
P3SCRAM >> clientFirstMessage [
	"This is the first message that the client sends to the server 
	to start the authentication process. You have to initialize me
	with either SHA1 or SHA256, a required password and an optional user identity."
	
	^ self channelBinding , self clientFirstMessageBare
]

{ #category : #private }
P3SCRAM >> clientFirstMessageBare [
	^ 'n=' , (self user ifNil: [ '' ])
		, ',r=' , self clientNounce
]

{ #category : #private }
P3SCRAM >> clientKey [
	^ hmac 
		key: self saltedPassword; 
		digestMessage: 'Client Key'
]

{ #category : #accessing }
P3SCRAM >> clientNounce [
	^ clientNounce ifNil: [ clientNounce := UUID new asString36 first: 16 ]
]

{ #category : #accessing }
P3SCRAM >> clientNounce: string [
	clientNounce := string
]

{ #category : #private }
P3SCRAM >> clientProof [
	^ self clientKey bitXor: self clientSignature 
]

{ #category : #private }
P3SCRAM >> clientSignature [
	^ hmac 
		key: self storedKey; 
		digestMessage: self authMessage 
]

{ #category : #accessing }
P3SCRAM >> fullNounce [
	^ self clientNounce , self serverNounce 
]

{ #category : #accessing }
P3SCRAM >> iterations [
	^ iteratedHash iterations
]

{ #category : #accessing }
P3SCRAM >> iterations: count [
	self iterations = count
		ifTrue: [ ^ self ].
	iteratedHash iterations: count.
	self clearSaltedPassword 
]

{ #category : #accessing }
P3SCRAM >> password [
	^ password
]

{ #category : #accessing }
P3SCRAM >> password: string [
	password = string
		ifTrue: [ ^ self ].
	password := string.
	self clearSaltedPassword
]

{ #category : #accessing }
P3SCRAM >> salt [
	^ salt
]

{ #category : #accessing }
P3SCRAM >> salt: byteArray [
	salt = byteArray
		ifTrue: [ ^ self ].
	salt := byteArray.
	self clearSaltedPassword 
]

{ #category : #private }
P3SCRAM >> saltedPassword [
	"Cached to improve performance"
	
	^ saltedPassword ifNil: [ 
			saltedPassword := iteratedHash 
				password: self password utf8Encoded; 
				salt: self salt; 
				deriveKey ]
]

{ #category : #public }
P3SCRAM >> serverFinalMessage: string [
	"This is the response message that the server sends to the client
	answering a previous clientFinalMessage. If there is no error,
	it contains a proof that is verified and asserted."
	
	| info |
	info := self class parseMessage: string.
	info at: #e ifPresent: [ :errorMessage | 
		^ self error: 'P3SCRAM Error: ' , errorMessage ].
	self assert: (info at: #v) base64Decoded = self serverSignature
]

{ #category : #private }
P3SCRAM >> serverFirstMessage [
	^ 'r=' , self fullNounce 
		, ',s=' , self salt base64Encoded 
		, ',i=' , iteratedHash iterations asString
]

{ #category : #public }
P3SCRAM >> serverFirstMessage: string [
	"This is the challenge message that the server sends to the client 
	in response to my clientFirstMessage. Parse it and process its contents."
	
	| info r |
	info := self class parseMessage: string.
	self salt: (info at: #s) base64Decoded.
	self iterations: (info at: #i) asInteger.
	r := info at: #r.
	self assert: (r beginsWith: self clientNounce).
	self serverNounce: (r allButFirst: self clientNounce size)
]

{ #category : #private }
P3SCRAM >> serverKey [
	^ hmac
		key: self saltedPassword;
		digestMessage: 'Server Key'
]

{ #category : #accessing }
P3SCRAM >> serverNounce [
	^ serverNounce ifNil: [ serverNounce := UUID new asString36 last: 16 ]
]

{ #category : #accessing }
P3SCRAM >> serverNounce: string [
	serverNounce := string
]

{ #category : #private }
P3SCRAM >> serverSignature [
	^ hmac
		key: self serverKey;
		digestMessage: self authMessage 
]

{ #category : #initialization }
P3SCRAM >> sha1 [
	hash := SHA1 new.
	hmac := hash hmac.
	iteratedHash := P3PBKDF2 new hmacSHA1.
]

{ #category : #initialization }
P3SCRAM >> sha256 [
	hash := SHA256 new.
	hmac := hash hmac.
	iteratedHash := P3PBKDF2 new hmacSHA256.
]

{ #category : #private }
P3SCRAM >> storedKey [
	^ hash hashMessage: self clientKey 
]

{ #category : #accessing }
P3SCRAM >> user [
	^ user
]

{ #category : #accessing }
P3SCRAM >> user: string [
	user := string
]
