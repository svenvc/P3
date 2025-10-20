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
