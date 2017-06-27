testing
testEmptyString
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	client execute: 'INSERT INTO table1 (id, string) VALUES (1, '''')'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result third first equals: #(1 '').
	client execute: 'INSERT INTO table1 (id, string) VALUES (2, NULL)'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 2'.
	self assert: result third first equals: #(2 nil).
	client execute: 'DROP TABLE table1'