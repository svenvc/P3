testing
testStringEscaping
	| result string |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id INTEGER, string VARCHAR)'.
	string := 'An SQL string with a single quote '' and a double quote ".'.
	"We can use #printString as Pharo strings are similar to SQL string"
	client execute: ('INSERT INTO table1 (id, string) VALUES ({1}, {2})' format: { 1. string printString }).
	result := client query: 'SELECT id, string FROM table1 WHERE id = 1'.
	self assert: result firstRecord equals: { 1. string }.
	client execute: 'DROP TABLE table1'