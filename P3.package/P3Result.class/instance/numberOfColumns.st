accessing
numberOfColumns
	^ self hasDescriptions ifTrue: [ self descriptions size ] ifFalse: [ 0 ]