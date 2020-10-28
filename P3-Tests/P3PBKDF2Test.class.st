"
Unit tests for P3PBKDF2

https://tools.ietf.org/html/rfc6070
https://stackoverflow.com/questions/5130513/pbkdf2-hmac-sha2-test-vectors
"
Class {
	#name : #P3PBKDF2Test,
	#superclass : #TestCase,
	#instVars : [
		'pbkdf2'
	],
	#category : #'P3-Tests'
}

{ #category : #running }
P3PBKDF2Test >> setUp [
	super setUp.
	pbkdf2 := P3PBKDF2 new
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector1 [
	| dk expected |
	pbkdf2 
		hmacSHA1; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 1.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('0c 60 c8 0f 96 1f 0e 71
            f3 a9 b5 24 af 60 12 06
            2f e0 37 a6' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector2 [
	| dk expected |
	pbkdf2 
		hmacSHA1; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 2.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('ea 6c 01 4d c7 2d 6f 8c
            cd 1e d9 2a ce 1d 41 f0
            d8 de 89 57' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector3 [
	| dk expected |
	pbkdf2 
		hmacSHA1; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('4b 00 79 01 b7 65 48 9a
            be ad 49 d9 26 f7 21 d0
            65 a4 29 c1' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector4 [
	"This takes several minutes, but it does pass"
	
"| dk expected |
dk := P3PBKDF2 new 
	hmacSHA1; 
	password: 'password'; 
	salt: 'salt'; 
	iterations: 16777216;
	deriveKey.
expected := ByteArray readHexFrom: ('ee fe 3d 61 cd 4d a4 e4
            e9 94 5b 3d 6b a2 15 8c
            26 34 e9 84' reject: #isSeparator).
self assert: dk = expected"
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector5 [
	| dk expected |
	pbkdf2 
		hmacSHA1; 
		password: 'passwordPASSWORDpassword'; 
		salt: 'saltSALTsaltSALTsaltSALTsaltSALTsalt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKeyOfSize: 25.
	expected := ByteArray readHexFrom: ('3d 2e ec 4f e4 1c 84 9b
            80 c8 d8 36 62 c0 e4 4a
            8b 29 1a 96 4c f2 f0 70
            38' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA1Vector6 [
	| dk expected |
	pbkdf2 
		hmacSHA1; 
		password: 'pass' , 0 asCharacter asString , 'word'; 
		salt: 'sa' , 0 asCharacter asString , 'lt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKeyOfSize: 16.
	expected := ByteArray readHexFrom: ('56 fa 6a a7 55 48 09 9d
            cc 37 d7 f0 34 25 e0 c3' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector1 [
	| dk expected |
	pbkdf2 
		hmacSHA256; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 1.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('12 0f b6 cf fc f8 b3 2c
       43 e7 22 52 56 c4 f8 37
       a8 65 48 c9 2c cc 35 48
       08 05 98 7c b7 0b e1 7b' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector2 [
	| dk expected |
	pbkdf2 
		hmacSHA256; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 2.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('ae 4d 0c 95 af 6b 46 d3
       2d 0a df f9 28 f0 6d d0
       2a 30 3f 8e f3 c2 51 df
       d6 e2 d8 5a 95 47 4c 43' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector3 [
	| dk expected |
	pbkdf2 
		hmacSHA256; 
		password: 'password'; 
		salt: 'salt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKey.
	expected := ByteArray readHexFrom: ('c5 e4 78 d5 92 88 c8 41
       aa 53 0d b6 84 5c 4c 8d
       96 28 93 a0 01 ce 4e 11
       a4 96 38 73 aa 98 13 4a' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector4 [
	"This takes several minutes, but it does pass"
	
"| dk expected |
dk := P3PBKDF2 new 
	hmacSHA256; 
	password: 'password'; 
	salt: 'salt'; 
	iterations: 16777216;
	deriveKey.
expected := ByteArray readHexFrom: ('cf 81 c6 6f e8 cf c0 4d
       1f 31 ec b6 5d ab 40 89
       f7 f1 79 e8 9b 3b 0b cb
       17 ad 10 e3 ac 6e ba 46' reject: #isSeparator).
self assert: dk = expected"
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector5 [
	| dk expected |
	pbkdf2 
		hmacSHA256; 
		password: 'passwordPASSWORDpassword'; 
		salt: 'saltSALTsaltSALTsaltSALTsaltSALTsalt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKeyOfSize: 40.
	expected := ByteArray readHexFrom: ('34 8c 89 db cb d3 2b 2f
       32 d8 14 b8 11 6e 84 cf
       2b 17 34 7e bc 18 00 18
       1c 4e 2a 1f b8 dd 53 e1
       c6 35 51 8c 7d ac 47 e9' reject: #isSeparator).
	self assert: dk equals: expected  
]

{ #category : #tests }
P3PBKDF2Test >> testHMACSHA256Vector6 [
	| dk expected |
	pbkdf2 
		hmacSHA256; 
		password: 'pass' , 0 asCharacter asString , 'word'; 
		salt: 'sa' , 0 asCharacter asString , 'lt'; 
		iterations: 4096.
	dk := pbkdf2 deriveKeyOfSize: 16.
	expected := ByteArray readHexFrom: ('89 b6 9d 05 16 f8 29 89
       3c 69 62 26 65 0a 86 87' reject: #isSeparator).
	self assert: dk equals: expected  
]
