private messages
md5PasswordMessage: salt
	"concat('md5', md5(concat(md5(concat(password, username)), random-salt))).
	Keep in mind the md5() function returns its result as a hex string."
	
	| credential salted |
	self password ifNil: [ self error: 'Password required' ].
	credential := (MD5 hashMessage: self password , self user) hex.
	salted := (MD5 hashMessage: credential , salt) hex.
	^ self asCString: 'md5' , salted