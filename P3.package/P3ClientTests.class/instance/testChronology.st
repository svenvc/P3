testing
testChronology
	| result |
	client execute: 'DROP TABLE IF EXISTS table1'.
	client execute: 'CREATE TABLE table1 (id SERIAL PRIMARY KEY, name TEXT, timestamp_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP, date_created DATE DEFAULT CURRENT_DATE, time_created TIME DEFAULT CURRENT_TIME)'.
	client execute: 'INSERT INTO table1 (name) VALUES (''Chronology'')'.
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 1'.
	result := result third first.
	self assert: result first equals: 1.
	self assert: result second equals: 'Chronology'.
	self assert: (DateAndTime now - result third) abs < 30 seconds.
	self assert: (Date today - result fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result fifth asSeconds) abs < 30.
	client execute: ('INSERT INTO table1 (name, timestamp_created, date_created, time_created) VALUES (''{1}'', ''{2}'', ''{3}'', ''{4}'')'
		format: { 'Pharo'. DateAndTime now. Date today. Time now }).
	result := client query: 'SELECT id, name, timestamp_created, date_created, time_created FROM table1 WHERE id = 2'.
	result := result third first.
	self assert: result first equals: 2.
	self assert: result second equals: 'Pharo'.
	self assert: (DateAndTime now - result third) abs < 30 seconds.
	self assert: (Date today - result fourth) abs < 30 seconds.
	self assert: (Time now asSeconds - result fifth asSeconds) abs < 30.
	client execute: 'DROP TABLE table1'