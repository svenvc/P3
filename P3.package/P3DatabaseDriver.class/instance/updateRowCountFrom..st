private
updateRowCountFrom: anObject
	anObject 
		ifNil: [ ^ rowCount := 0 ].
	rowCount := anObject isString
		ifTrue: [ 
			($ split: anObject) last asInteger ]
		ifFalse: [ 
			anObject 
				inject: 0 
				into: [ :sum :next | sum + ($ split: next) last asInteger ] ]