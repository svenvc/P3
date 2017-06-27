accessing
port
	^ port ifNil: [ port := 5432 ]