testing
testSqlFunction
	| x y result |
	client execute: 'DROP FUNCTION IF EXISTS my_add(x INTEGER, y INTEGER)'.
	client execute: 'CREATE FUNCTION my_add(x INTEGER, y INTEGER) RETURNS INTEGER AS $$ SELECT x + y $$ LANGUAGE SQL'.
	x := 99 atRandom.
	y := 99 atRandom.
	result := client query: ('SELECT my_add({1},{2}) AS answer' format: { x. y }).
	self assert: result firstFieldOfFirstRecord equals: x + y.
	client execute: 'DROP FUNCTION my_add(x INTEGER, y INTEGER)'.