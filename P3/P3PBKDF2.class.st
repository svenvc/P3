"
I am P3PBKDF2 (Password-Based Key Derivation Function 2).

https://en.wikipedia.org/wiki/PBKDF2
https://tools.ietf.org/html/rfc2898

	P3PBKDF2 new
		hmacSHA1; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 4096;
		deriveKey.
"
Class {
	#name : 'P3PBKDF2',
	#superclass : 'Object',
	#instVars : [
		'password',
		'salt',
		'pseudoRandom',
		'iterations'
	],
	#category : 'P3-Support',
	#package : 'P3',
	#tag : 'Support'
}

{ #category : 'public' }
P3PBKDF2 >> deriveKey [
	"Derive and return a key based on my settings.
	The size will conform with the block size of my pseudo random function."
	
	^ self deriveKeyBlock: 1
]

{ #category : 'private' }
P3PBKDF2 >> deriveKeyBlock: blockNumber [
	| data derivedKeyBlock |
	data := self pseudoRandom: password with: (self saltFor: blockNumber).
	derivedKeyBlock := data.
	(iterations - 1) timesRepeat: [ 
		data := self pseudoRandom: password with: data.
		derivedKeyBlock := derivedKeyBlock bitXor: data ].
	^ derivedKeyBlock  
]

{ #category : 'public' }
P3PBKDF2 >> deriveKeyOfSize: byteSize [
	"Derive and return a byteSize key based on my settings."

	| blockNumber bytesProduced derivedKeyBlock count |
	blockNumber := 1.
	bytesProduced := 0.
	^ ByteArray new: byteSize streamContents: [ :out |
		[ bytesProduced < byteSize ] whileTrue: [ 
			derivedKeyBlock := self deriveKeyBlock: blockNumber.
			blockNumber := blockNumber + 1.
			count := (byteSize - bytesProduced) min: derivedKeyBlock size.
			out next: count putAll: derivedKeyBlock.
			bytesProduced := bytesProduced + count ] ]
]

{ #category : 'initialization' }
P3PBKDF2 >> hmacSHA1 [
	self pseudoRandom: [ :key :message | 
		SHA1 new hmac key: key; digestMessage: message ]
]

{ #category : 'initialization' }
P3PBKDF2 >> hmacSHA256 [
	self pseudoRandom: [ :key :message | 
		SHA256 new hmac key: key; digestMessage: message ]
]

{ #category : 'accessing' }
P3PBKDF2 >> iterations [
	^ iterations
]

{ #category : 'accessing' }
P3PBKDF2 >> iterations: numberOfRounds [
	iterations := numberOfRounds
]

{ #category : 'accessing' }
P3PBKDF2 >> password [
	^ password
]

{ #category : 'accessing' }
P3PBKDF2 >> password: anObject [
	password := anObject asByteArray
]

{ #category : 'accessing' }
P3PBKDF2 >> pseudoRandom [
	^ pseudoRandom
]

{ #category : 'accessing' }
P3PBKDF2 >> pseudoRandom: block [
	pseudoRandom := block
]

{ #category : 'private' }
P3PBKDF2 >> pseudoRandom: key with: message [
	^ pseudoRandom value: key value: message
]

{ #category : 'accessing' }
P3PBKDF2 >> salt [
	^ salt
]

{ #category : 'accessing' }
P3PBKDF2 >> salt: anObject [
	salt := anObject asByteArray
]

{ #category : 'private' }
P3PBKDF2 >> saltFor: blockNumber [
	^ salt , (blockNumber asByteArrayOfSize: 4)
]
