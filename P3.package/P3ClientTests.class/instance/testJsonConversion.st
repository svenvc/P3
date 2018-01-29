testing
testJsonConversion
	| data result |
	
	self supportsJsonB ifFalse: [ ^ self skip ].
	data := NeoJSONObject new 
		x: 1; 
		str: 'les élève Français'; 
		foo: 'tab' , Character tab asString; 
		bar: #(true nil -123); 
		yourself.
	result := client query: ('SELECT ''{1}''::json' format: { data printString }).
	self assert: result firstFieldOfFirstRecord equals: data.
	result := client query: ('SELECT ''{1}''::jsonb' format: { data printString }).
	self assert: result firstFieldOfFirstRecord equals: data