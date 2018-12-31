"
P3ArrayValueParserTest holds unit tests for P3ArrayValueParser.
"
Class {
	#name : #P3ArrayValueParserTest,
	#superclass : #TestCase,
	#category : #'P3-Tests'
}

{ #category : #tests }
P3ArrayValueParserTest >> testIntegers [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{1,2},{3,4},{0,-1}}' readStream;
			converter: [ :string | string asInteger ];
			next)
		equals: #( (1 2) (3 4) (0 -1) )
]

{ #category : #tests }
P3ArrayValueParserTest >> testPlain [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{one,two},{three,four},{NULL,""}' readStream;
			next)
		equals: #( ('one' 'two') ('three' 'four') (nil '') )
]

{ #category : #tests }
P3ArrayValueParserTest >> testSpecial [
	self 
		assert: (P3ArrayValueParser new 
			on: '{{one,two},{"\"","\\"},{NULL,""},{"NULL",1}' readStream;
			next)
		equals: #( ('one' 'two') ('"' '\') (nil '') ('NULL' '1') )

]
