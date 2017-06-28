accessing
totalRowCount
	results ifNil: [ ^ 0 ].
	^ results isString
		ifTrue: [ self firstRowCount ]
		ifFalse: [ results inject: 0 into: [ :sum :next | sum + (self rowCountFromCommandResultTag: next) ] ]