testing
testMultiStatement
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	result := client query: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true); INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	self assert: result first equals: #('INSERT 0 1' 'INSERT 0 1').
	self assert: result second isNil.
	self assert: result third isNil.
	result := client query: 'SELECT * from table1'.
	self assert: result first equals: 'SELECT 2'.
	self assert: result third equals: #((1 'foo' true)(2 'bar' false)).
	client execute: 'DROP TABLE table1'