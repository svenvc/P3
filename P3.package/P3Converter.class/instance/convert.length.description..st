converting
convert: bytes length: length description: description
	| type |
	type := map 
		at: description typeOid 
		ifAbsent: [ self error: 'P3 cannot convert typeOid ', description typeOid asString ].
	^ self perform: type second with: bytes with: length with: description 