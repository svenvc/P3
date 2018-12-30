"
P3ArrayValueParserTests holds unit tests for P3ArrayValueParser.
"
Class {
	#name : #P3ArrayValueParserTests,
	#superclass : #TestCase,
	#category : #P3
}

{ #category : #tests }
P3ArrayValueParserTests >> testIntegers [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{1,2},{3,4},{0,-1}}' readStream;
			converter: [ :string | string asInteger ];
			next)
		equals: #( (1 2) (3 4) (0 -1) )
]

{ #category : #tests }
P3ArrayValueParserTests >> testPlain [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{one,two},{three,four},{NULL,""}' readStream;
			next)
		equals: #( ('one' 'two') ('three' 'four') (nil '') )
]

{ #category : #tests }
P3ArrayValueParserTests >> testSpecial [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{one,two},{"\"","\\"},{NULL,""},{"NULL",1}' readStream;
			next)
		equals: #( ('one' 'two') ('"' '\') (nil '') ('NULL' '1') )

]
