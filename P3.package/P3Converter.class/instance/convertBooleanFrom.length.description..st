converting
convertBooleanFrom: bytes length: length description: description
	self assert: length = 1.
	^ bytes next = $t charCode