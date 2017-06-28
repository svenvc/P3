accessing
addResult: subResult
	results := results
		ifNil: [ subResult ]
		ifNotNil: [ results isString
				ifTrue: [ Array with: results with: subResult ]
				ifFalse: [ results copyWith: subResult ] ]