converting
convert: bytes length: length description: description

	| type lambda |
	
	type := map at: description typeOid 
		ifAbsent: [ self error: 'P3 cannot convert typeOid ', description typeOid asString ].
		
	lambda := type second.
	
	^ lambda isSymbol 
		ifTrue: [ self perform: type second with: bytes with: length with: description ]
		ifFalse: [ lambda value: bytes value: length value: description ]