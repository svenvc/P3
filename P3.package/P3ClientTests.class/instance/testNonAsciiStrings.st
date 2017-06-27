testing
testNonAsciiStrings
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	client execute: 'INSERT INTO table1 (id, string) VALUES (1, ''Les élèves Français'')'.
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result third first equals: #(1 'Les élèves Français').
	client execute: ('INSERT INTO table1 (id, string) VALUES (2, ''100 {1}'')' format: { Character euro }).
	result := client query: 'SELECT id, string FROM table1 WHERE id = 2'.
	self assert: result third first equals: {2. '100 {1}' format: { Character euro }}.
	client execute: 'DROP TABLE table1'