testing
testUuid

	| result uuid num |
	
	client execute: 'DROP TABLE IF EXISTS testUUID'.
	client execute: 'CREATE TABLE testUUID (id UUID, num INTEGER)'.
	
	uuid := UUID new.
	num := 1234 atRandom.
	
	client execute: ('INSERT INTO testUUID (id, num) VALUES (''{1}'', {2})' format: { uuid. num }).
	result := client query: ('SELECT * FROM testUUID WHERE id = ''{1}''' format: {uuid}).
	
	self assert: result firstRecord equals: { uuid. num }.
	
	client execute: 'DROP TABLE testUUID'