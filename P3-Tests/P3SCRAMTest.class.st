"
Unit tests for P3SCRAM.

https://tools.ietf.org/html/rfc5802
https://tools.ietf.org/html/rfc7677

"
Class {
	#name : 'P3SCRAMTest',
	#superclass : 'TestCase',
	#instVars : [
		'scram'
	],
	#category : 'P3-Tests',
	#package : 'P3-Tests'
}

{ #category : 'running' }
P3SCRAMTest >> setUp [
	super setUp.
	scram := P3SCRAM new
]

{ #category : 'tests' }
P3SCRAMTest >> testConcurrentAuthenticationRaceCondition [
	"Demonstrates that concurrent authentications against the same URL must not share mutable state machine nonces."

	| client1 client2 scram1 scram2 challenge1 challenge2 final1 |
	client1 := P3Client url: 'psql://user:pencil@localhost:5432/db'.
	client2 := P3Client url: 'psql://user:pencil@localhost:5432/db'.

	scram1 := client1 scramSHA256.
	scram2 := client2 scramSHA256.

	scram1 clientFirstMessage.
	scram2 clientFirstMessage.

	challenge1 := 'r=' , scram1 clientNounce , 'sn1,s=W22ZaJ0SNY7soEsUEjb6gQ==,i=10'.
	scram1 serverFirstMessage: challenge1.

	challenge2 := 'r=' , scram2 clientNounce , 'sn2,s=W22ZaJ0SNY7soEsUEjb6gQ==,i=10'.
	scram2 serverFirstMessage: challenge2.

	final1 := scram1 clientFinalMessage.

	self deny: scram1 identicalTo: scram2.
	self
		assert: (final1 includesSubstring: 'sn1')
		description: 'Client 1 final message must contain its own server nonce'.
	self
		deny: (final1 includesSubstring: 'sn2')
		description: 'Client 1 final message must not contain Client 2 server nonce'
]

{ #category : 'tests' }
P3SCRAMTest >> testSHA1 [
	scram sha1.
	scram user: 'user'.
	scram password: 'pencil'.
	scram clientNounce: 'fyko+d2lbbFgONRv9qkxdawL'.
	self 
		assert: scram clientFirstMessage 
		equals: 'n,,n=user,r=fyko+d2lbbFgONRv9qkxdawL'.
	scram serverFirstMessage: 'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096'.
	self assert: scram serverNounce equals: '3rfcNHYJY1ZVvWVs7j'.
	self assert: scram salt base64Encoded equals: 'QSXCR+Q6sek8bf92'.
	self assert: scram iterations equals: 4096.
	self 
		assert: scram clientFinalMessage 
		equals: 'c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts='.
	scram serverFinalMessage: 'v=rmF9pqV8S7suAoZWja4dJRkFsKQ='
	
]

{ #category : 'tests' }
P3SCRAMTest >> testSHA256 [
	scram sha256.
	scram user: 'user'.
	scram password: 'pencil'.
	scram clientNounce: 'rOprNGfwEbeRWgbNEkqO'.
	self 
		assert: scram clientFirstMessage 
		equals: 'n,,n=user,r=rOprNGfwEbeRWgbNEkqO'.
	scram serverFirstMessage: 'r=rOprNGfwEbeRWgbNEkqO%hvYDpWUa2RaTCAfuxFIlj)hNlF$k0,s=W22ZaJ0SNY7soEsUEjb6gQ==,i=4096'.
	self assert: scram serverNounce equals: '%hvYDpWUa2RaTCAfuxFIlj)hNlF$k0'.
	self assert: scram salt base64Encoded equals: 'W22ZaJ0SNY7soEsUEjb6gQ=='.
	self assert: scram iterations equals: 4096.
	self 
		assert: scram clientFinalMessage 
		equals: 'c=biws,r=rOprNGfwEbeRWgbNEkqO%hvYDpWUa2RaTCAfuxFIlj)hNlF$k0,p=dHzbZapWIk4jUhN+Ute9ytag9zjfMHgsqmmiz7AndVQ='.
	scram serverFinalMessage: 'v=6rriTRBi23WpRR/wtup+mMhUZUn/dB5nLTJRsjl95G4='
	
]
