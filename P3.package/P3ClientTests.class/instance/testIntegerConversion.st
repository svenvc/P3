testing
testIntegerConversion
	| result |
	result := client query: 'SELECT i::integer FROM (VALUES (-1), (1), (NULL), (1234567890)) t(i)'.
	self assert: result data equals: #((-1) (1) (nil) (1234567890))