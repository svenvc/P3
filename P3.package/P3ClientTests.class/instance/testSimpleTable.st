testing
testSimpleTable
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
	client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (NULL, NULL, NULL)'.
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: #(1 'foo' true).
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: #(2 'bar' false).
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id IS NULL'.
	self assert: result firstRecord equals: #(nil nil nil).
	client execute: 'DELETE FROM table1 WHERE id IS NULL'.
	client execute: 'UPDATE table1 SET name = ''xxx'' WHERE id = 2'.
	result := client query: 'SELECT id, name, enabled FROM table1 WHERE id = 2'.
	self assert: result firstRecord equals: #(2 'xxx' false).
	client execute: 'DROP TABLE table1'