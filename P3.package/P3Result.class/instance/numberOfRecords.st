accessing
numberOfRecords
	^ self hasData ifTrue: [ self data size ] ifFalse: [ 0 ]