I am P3Client, a lean and mean PostgreSQL client.

PostgreSQL, often simply Postgres, is a free and open-source, ACID-compliant and transactional object-relational database management system (ORDBMS).

I use frontend/backend protocol 3.0 (PostgreSQL version 7.4 [2003] and later), implementing the simple query cycle. I support plaintext and md5 password authentication. When SQL queries return row data, I efficiently convert incoming data to objects. I support most common PostgreSQL types (P3Converter supportedTypes).

I can be configured manually or through a URL.

  P3Client new url: 'psql://username:password@localhost:5432/databasename'.

Not all properties need to be specified, the minimum is the following URL.

  P3Client new url: 'psql://user@localhost'.

I have a minimal public protocol, basically #query: (#execute: is an alias).

Opening a connection to the server (#open) and running the authentication and startup protocols (#connect) are done automatically when needed from #query.

I also support SSL connections. Use #connectSSL to initiate such a connection.

I represent a single database connection or session, I am not thread safe.


Examples 

Here is how to create a simple table with some rows in it.

	(P3Client new url: 'psql://sven@localhost') in: [ :client |
		client execute: 'DROP TABLE IF EXISTS table1'.
		client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
		client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
		client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
		client close ].
	
Now we can query the contents of the simple table we just created.

	(P3Client new url: 'psql://sven@localhost') in: [ :client |
		[ client query: 'SELECT * FROM table1' ] ensure: [ client close ] ].

The result is a triplet, { result. descriptions. data }

  an Array(
    'SELECT 2' 
    an Array(a P3RowFieldDescription(id int4) a P3RowFieldDescription(name text) a P3RowFieldDescription(enabled bool)) 
    #(#(1 'foo' true) #(2 'bar' false)))

Result is a string (collection of strings for multiple embedded queries) indicating successful execution.
Descriptions is a collection of row field description objects.
Data is a collection of rows with fully converted field values as objects.

Finally we can clean up.

	(P3Client new url: 'psql://sven@localhost') in: [ :client |
		[ client execute: 'DROP TABLE table1' ] ensure: [ client close ] ].


References 

  https://postgresql.org
  https://en.wikipedia.org/wiki/PostgreSQL
  https://www.postgresql.org/docs/9.6/static/protocol.html


See also P3DatabaseDriver, an interface between Glorp, an advanced object-relational mapper, and me.
