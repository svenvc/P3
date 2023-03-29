"
I represent a Parser which can parse ancient PostgreSQL oidvector (OID:30) type, which looks like array of positive integers, but has different textual representation. Example of the textual representation: '2281 26 2281 21 2281'.

We have four different vector types:

```sql
select distinct typname from pg_type where typname ~ '^[^_].*vector';
```

```
┌─────────────┐
│   typname   │
├─────────────┤
│ gtsvector   │
│ int2vector  │
│ oidvector   │
│ tsvector    │
└─────────────┘
```
"
Class {
	#name : #P3IntegerVectorValueParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'converter'
	],
	#category : #'P3-Support'
}

{ #category : #'private-parsing' }
P3IntegerVectorValueParser >> consumeWhitespace [

	"Strip whitespaces from the input stream."

	[ stream atEnd not and: [ stream peek = Character space ] ] 
		whileTrue: [ stream next ]
]

{ #category : #'private-parsing' }
P3IntegerVectorValueParser >> convertElement: string [
	^ converter 
		ifNil: [ string ]
		ifNotNil: [ converter value: string ]
]

{ #category : #'instance creation' }
P3IntegerVectorValueParser >> converter: block [
	"Set my converter to block, which will parse the text of array elements"
	
	converter := block
]

{ #category : #initialization }
P3IntegerVectorValueParser >> initialize [

	"set default converter"

	super initialize.
	converter := [ :string |  string asInteger]
]

{ #category : #accessing }
P3IntegerVectorValueParser >> next [

	"Parse and return the next array value"

	self consumeWhitespace.
	^ Array streamContents: [ :array | 
		  [ stream atEnd ] 
			  whileFalse: [ 
				  array nextPut: (self convertElement: self parseElement).
				  self consumeWhitespace.] ]
]

{ #category : #'instance creation' }
P3IntegerVectorValueParser >> on: readStream [
	"Initialize me on the textual readStream given"
	
	stream := readStream
]

{ #category : #'private-parsing' }
P3IntegerVectorValueParser >> parseElement [

	^ String streamContents: [ :string | 
		  [ stream atEnd or: [ Character space = stream peek ] ] 
			  whileFalse: [ string nextPut: stream next ] ]
]
