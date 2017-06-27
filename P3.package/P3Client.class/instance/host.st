accessing
host
	^ host ifNil: [ host := 'localhost' ]