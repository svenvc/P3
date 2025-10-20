Class {
	#name : 'P3IntegerVectorValueParserTest',
	#superclass : 'TestCase',
	#category : 'P3-Tests',
	#package : 'P3-Tests'
}

{ #category : 'tests' }
P3IntegerVectorValueParserTest >> testPlain [

	"assuming PostgreSQL will always use exactly one space as separator, but we parse multispace as well"

	self
		assert: (P3IntegerVectorValueParser new
				 on: '  12   1221 0 -123 1221   12  ' readStream;
				 next)
		equals: #( 12 1221 0 -123 1221 12 )
]
