testing
testMultiStatement
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	result := client query: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true); INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	self assert: result results equals: #('INSERT 0 1' 'INSERT 0 1').
	self deny: result hasDescriptions.
	self deny: result hasData.
	result := client query: 'SELECT * from table1'.
	self assert: result firstResult equals: 'SELECT 2'.
	self assert: result firstRowCount equals: 2.
	self assert: result data equals: #((1 'foo' true)(2 'bar' false)).
	client execute: 'DROP TABLE table1'