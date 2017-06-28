testing
testBooleanConversion
	| result |
	result := client query: 'SELECT b::boolean FROM (VALUES (true), (false), (NULL)) t(b)'.
	self assert: result data equals: #((true) (false) (nil))