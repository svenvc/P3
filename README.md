# P3

P3 is a modern, lean and mean PostgreSQL client for Pharo.

[![Build Status](https://travis-ci.org/svenvc/P3.svg?branch=master)](https://travis-ci.org/svenvc/P3)

**P3Client** uses frontend/backend protocol 3.0 (PostgreSQL version 7.4 [2003] and later),
implementing the simple query cycle. It supports plaintext and md5 password authentication.
When SQL queries return row data, it efficiently converts incoming data to objects.
P3Client supports most common PostgreSQL types.

P3Client can be configured manually or through a URL.

```smalltalk
P3Client new url: 'psql://username:password@localhost:5432/databasename'.
```

Not all properties need to be specified, the minimum is the following URL.

```smalltalk
P3Client new url: 'psql://user@localhost'.
```

P3Client has a minimal public protocol, basically #query: (#execute: is an alias).

Opening a connection to the server (#open) and running the authentication
and startup protocols (#connect) are done automatically when needed from #query.

P3Client also supports SSL connections. Use #connectSSL to initiate such a connection.


## Usage

Here is the simplest test that does an actual query, it should return true.

```smalltalk
(P3Client new url: 'psql://sven@localhost') in: [ :client |
   [ client isWorking ] ensure: [ client close ] ].
```

This is how to create a simple table with some rows in it.

```smalltalk
(P3Client new url: 'psql://sven@localhost') in: [ :client |
   client execute: 'DROP TABLE IF EXISTS table1'.
   client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)'.
   client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (1, ''foo'', true)'.
   client execute: 'INSERT INTO table1 (id, name, enabled) VALUES (2, ''bar'', false)'.
   client close ].
```

Now we can query the contents of the simple table we just created.

```smalltalk
(P3Client new url: 'psql://sven@localhost') in: [ :client |
   [ client query: 'SELECT * FROM table1' ] ensure: [ client close ] ].
```

The result is an instance of P3Result

```smalltalk
   a P3Result('SELECT 2' 2 records 3 colums)
```

P3Result contains 3 elements,  results, descriptions & data:
- Results is a string (collection of strings for multiple embedded queries) indicating successful execution.
- Descriptions is a collection of row field description objects.
- Data is a collection of rows with fully converted field values as objects.

The data itself is an array with 2 sub arrays, one for each record.

```smalltalk
#( #(1 'foo' true) #(2 'bar' false) )
```

Finally we can clean up.

```smalltalk
(P3Client new url: 'psql://sven@localhost') in: [ :client |
   [ client execute: 'DROP TABLE table1' ] ensure: [ client close ] ].
```


## References

-  https://postgresql.org
-  https://en.wikipedia.org/wiki/PostgreSQL
-  https://www.postgresql.org/docs/9.6/static/protocol.html


## Glorp

Included is **P3DatabaseDriver**, an interface between Glorp, an advanced object-relational mapper, and P3Client.

To install this driver (after loading Glorp itself), do

```smalltalk
PharoDatabaseAccessor DefaultDriver: P3DatabaseDriver.
```

Configure your session using a Glorp Login object

```smalltalk
Login new
   database: PostgreSQLPlatform new;
   username: 'username';
   password: 'password';
   connectString: 'host:5432_databasename';
   encodingStrategy: #utf8;
   yourself.
```


## Code loading

The default group loads P3Client and its basic dependencies NeoJSON and ZTimestamp

```smalltalk
Metacello new
   baseline: 'P3';
   repository: 'github://svenvc/P3';
   load.
```

The glorp group loads P3DatabaseDriver and the whole of Glorp (warning: large download)

```smalltalk
Metacello new
   baseline: 'P3';
   repository: 'github://svenvc/P3';
   load: 'glorp'.
```

## Unit tests

**P3ClientTests** holds unit tests for the P3 PSQL client.

Configure it by setting its class side's connection URL.

```smalltalk
P3ClientTests url: 'psql://sven:secret@localhost:5432/database'.
```

The minimal being the following:

```smalltalk
P3ClientTests url: 'psql://sven@localhost'.
```
