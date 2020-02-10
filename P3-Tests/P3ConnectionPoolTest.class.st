"
P3ConnectionPoolTest holds unit tests for the P3ConnectionPool class.

I reuse the configuration of P3ClientTest.
"
Class {
	#name : #P3ConnectionPoolTest,
	#superclass : #TestCase,
	#instVars : [
		'pool'
	],
	#category : #'P3-Tests'
}

{ #category : #running }
P3ConnectionPoolTest >> setUp [
	super setUp.
	pool := P3ConnectionPool new.
	pool url: P3ClientTest url
]

{ #category : #running }
P3ConnectionPoolTest >> tearDown [
	pool close
]

{ #category : #tests }
P3ConnectionPoolTest >> testError [
	self assert: pool size equals: 0.
	self 
		should: [ pool withConnection: [ :p3Client | 
							p3Client query: 'SELECT * FROM abcdef'] ] 
		raise: P3Error.
	self assert: pool size equals: 0
]

{ #category : #tests }
P3ConnectionPoolTest >> testOne [
	self assert: pool size equals: 0.
	self 
		assert: (pool withConnection: [ :p3Client | 
							(p3Client query: 'SELECT 1+2') firstFieldOfFirstRecord ]) 
		equals: 3.
	self 
		assert: (pool withConnection: [ :p3Client | 
							(p3Client query: 'SELECT 10-2') firstFieldOfFirstRecord ]) 
		equals: 8.
	self assert: pool size equals: 1
]

{ #category : #tests }
P3ConnectionPoolTest >> testWarmUp [
	self assert: pool size equals: 0.
	pool warmUp.
	self assert: pool size equals: pool capacity.
	pool withConnection: [ :p3Client | 
		p3Client query: 'SELECT table_name FROM information_schema.tables' ].
	self assert: pool size equals: pool capacity.
	pool close.
	self assert: pool size equals: 0
]
