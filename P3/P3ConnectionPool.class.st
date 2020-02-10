"
I am P3ConnectionPool.

I offer a pool of shared PSQL connections (P3Client instances) as a resource.

After configuring me with at least a url, you use me by calling #withConnection:

  pool := P3ConnectionPool url: 'psql://sven@localhost'.
  pool withConnection: [ :p3Client | 
	  p3Client query: 'SELECT table_name FROM information_schema.tables' ].
  pool close.

When a connection is in use, it is not part of the pool.
When a connection is returned/released to the pool, it becomes available for reuse.

The pool's size is the number of open connection ready to be reused.
The pool's capacity is the maximum number of connection that will be pooled.
Excess connections will be closed when they are returned/released to the pool.

New connections are created as needed.
You can set a #configurator to further initialize new connections.
You can use #warmUp or #warmUp: to precreate a number of connections.

When an error occurs, the connection should not be reused and be closed by the caller.

"
Class {
	#name : #P3ConnectionPool,
	#superclass : #Object,
	#instVars : [
		'url',
		'configurator',
		'pool',
		'access'
	],
	#category : #'P3-Core'
}

{ #category : #'instance creation' }
P3ConnectionPool class >> url: anUrl [
	^ self new url: anUrl
]

{ #category : #public }
P3ConnectionPool >> acquireConnection [
	"Return a connection (P3Client) from the pool or create a new one.
	While in use the connection (P3Client) is removed from the pool."
	
	^ access critical: [ 
		pool
			ifEmpty: [ self makeP3Client ] 
			ifNotEmpty: [ pool removeLast ] ]
]

{ #category : #accessing }
P3ConnectionPool >> capacity [
	^ pool capacity 
]

{ #category : #initialization }
P3ConnectionPool >> close [
	"Close all pooled connections and remove them"
	
	pool do: [ :each | each close ].
	pool removeAll
]

{ #category : #initialization }
P3ConnectionPool >> configurator: oneArgumentBlock [
	"Set oneArgumentBlock to be my configurator.
	This is code that will be executed once on each newly created connection (P3Client).
	The default configuration asserts #isWorking on the argument"
	
	configurator := oneArgumentBlock 
]

{ #category : #initialization }
P3ConnectionPool >> initialize [
	super initialize.
	access := Mutex new.
	pool := OrderedCollection new: 10.
	configurator := [ :p3Client | self assert: p3Client isWorking ]
]

{ #category : #private }
P3ConnectionPool >> makeP3Client [
	| p3Client |
	p3Client := P3Client url: url.
	configurator ifNotNil: [ configurator value: p3Client ].
	^ p3Client
]

{ #category : #printing }
P3ConnectionPool >> printOn: stream [
	super printOn: stream.
	stream 
		nextPut: $(; 
		print: self url; space; 
		print: self size; nextPut: $/; print: self capacity; 
		nextPut: $)
]

{ #category : #public }
P3ConnectionPool >> releaseConnection: connection [
	"Return connection (a P3Client) to the pool.
	If the pool is at its capacity, close it.
	After this, the caller can no longer use connection."
	
	access critical: [  
		pool size < pool capacity
			ifTrue: [ pool addLast: connection ]
			ifFalse: [ connection close ] ]
]

{ #category : #accessing }
P3ConnectionPool >> size [
	^ pool size
]

{ #category : #initialization }
P3ConnectionPool >> size: capacity [
	"Size me to capacity: the maximum number of connections (P3Clients) that I will hold"
	
	pool := OrderedCollection new: capacity
]

{ #category : #accessing }
P3ConnectionPool >> url [
	^ url
]

{ #category : #initialization }
P3ConnectionPool >> url: aPsqlUrl [
	"Set the P3Client url"
	
	url := aPsqlUrl 
]

{ #category : #public }
P3ConnectionPool >> warmUp [
	"Warm up the receiver to its full capacity.
	This will create all pooled connections at once."
	
	self warmUp: self capacity
]

{ #category : #public }
P3ConnectionPool >> warmUp: numberOfConnections [
	"Warm up the pool to numberOfConnections.
	Effectively creating that many connections at once"
	
	| connections |
	connections := Array streamContents: [ :out |
		numberOfConnections timesRepeat: [ 
			out nextPut: self acquireConnection ] ].
	connections do: [ :each | self releaseConnection: each ]
]

{ #category : #public }
P3ConnectionPool >> withConnection: oneArgumentBlock [
	"Execute oneArgumentBlock with a connection (P3Client) as argument,
	acquiring it from the pool and releasing it to the pool when done,
	unless an error occurs (in which case the caller should close)."
	
	| connection result error |
	connection := self acquireConnection.
	error := result := nil.
	[ [ result := oneArgumentBlock value: connection ] 
			on: Error 
			do: [ :exception | error := exception. error pass ] ] 
		ensure: [ error ifNil: [ self releaseConnection: connection ] ].
	^ result
]
