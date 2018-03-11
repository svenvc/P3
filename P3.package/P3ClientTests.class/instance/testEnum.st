testing
testEnum

	| result ooid |

	result := client 
		execute: 'DROP TABLE IF EXISTS table1;';
		execute: 'DROP TYPE IF EXISTS mood';
		execute: 'CREATE TYPE mood AS ENUM (''sad'', ''ok'', ''happy'');';
		execute: 'CREATE TABLE table1 (name text, current_mood mood );';
		execute: 'INSERT INTO table1 VALUES (''Moe'', ''happy'');'.
		
	result := client query: 'SELECT oid FROM pg_type WHERE typname = ''mood'';'.
	ooid := result firstRecord first.
	
	client converter 
		mapOid: ooid 
		type: #mood
		to: [ :reader :length :description | (reader next: length) asString asSymbol ].
		
	result := client query: 'SELECT * FROM table1 WHERE current_mood = ''happy'';'.
		
	self assert: result firstRecord equals: #('Moe' #happy)	
	
