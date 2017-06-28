testing
testTimezone
	| result originalTimezone |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, t1 TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP, t2 TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP)'.
	originalTimezone := client converter timezone id.
	client execute: ('INSERT INTO table1 (name) VALUES (''{1}'')' format: { originalTimezone }).
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	self assert: result firstRecord second equals: client converter timezone id.
	self assert: (DateAndTime now - result firstRecord third) abs < 30 seconds.
	self assert: (DateAndTime now - result firstRecord fourth) abs < 30 seconds.
	client execute: 'SET TIMEZONE TO ''GMT'''.
	result := client query: 'SHOW TIMEZONE'.
	self assert: result firstFieldOfFirstRecord equals: 'GMT'.
	client converter timezone: (ZTimezone gmt).
	client execute: ('INSERT INTO table1 (name) VALUES (''{1}'')' format: { client converter timezone id }).
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 1'.
	self assert: result firstRecord first equals: 1.
	"t1 is now off, since postgres did not adjust it"
	self assert: (DateAndTime now asUTC - result firstRecord fourth) abs < 30 seconds.
	result := client query: 'SELECT id, name, t1, t2 FROM table1 WHERE id = 2'.
	self assert: result firstRecord first equals: 2.
	self assert: result firstRecord second equals: client converter timezone id.
	self assert: (DateAndTime now asUTC - result firstRecord third) abs < 30 seconds.
	self assert: (DateAndTime now asUTC - result firstRecord fourth) abs < 30 seconds.
	client execute: ('SET TIMEZONE TO ''{1}''' format: { originalTimezone }).
	client converter timezone: (ZTimezone id: originalTimezone).
	client execute: 'DROP TABLE table1'