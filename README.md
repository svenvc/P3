# P3


P3 is a modern, lean and mean PostgreSQL client for Pharo.

[![CI](https://github.com/svenvc/P3/actions/workflows/CI.yml/badge.svg)](https://github.com/svenvc/P3/actions/workflows/CI.yml)

**P3Client** uses frontend/backend protocol 3.0 (PostgreSQL version 7.4 [2003] and later),
implementing the simple and extended query cycles. 
It supports plaintext, md5 and scram-sha-256 password authentication.
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
Alternatively you can add sslmode=require to the connection URL, as in
'psql://username:password@localhost:5432/databasename?sslmode=require'.

Through the #prepare: message, you can ask P3Client to prepare/parse an SQL statement or
query with parameters. This will give you a P3PreparedStatement instance than you can then
execute with specific parameters. Polymorphic to this there is also P3FormattedStatement
which you create using the #format: message. These work at the textual, client side level.


## Basic Usage

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


## Using Prepared and Formatted Statements

Although you are free to create your SQL statements in any way you see fit,
feeding them to #execute: and #query:,
inserting arguments in SQL statements can be hard (because you have to know the correct syntax),
error prone (because you might violate syntax rules) and dangerous (due to SQL injection attacks).

P3 can help here with two mechanisms: prepared and formatted statements.
They are mostly polymorphic and use the same template notation.
They allow you to create a statement once, specifying placeholders with $n, 
and execute it once or multiple times with concrete arguments,
with the necessary conversions happening automatically.

The difference between the two is that formatted statements are implemented 
using simple textual substitution on the client side, while
prepared statements are evaluated on the server side with full syntax checking,
and are executed with more type checks.
Prepared statements are more efficient since the server can do part of its optimalization
in the prepare phase, saving time on each execution.

Here is a transcript of how to use them. First we set up a client and create a test table.

```smalltalk
client := P3Client new url: 'psql://sven@localhost'.

client execute: 'DROP TABLE IF EXISTS table1'.
client execute: 'CREATE TABLE table1 (id INTEGER, name TEXT, weight REAL, enabled BOOLEAN)'.
```

Next we insert some data and then query it using prepared statements.

```smalltalk
statement := client prepare: 'INSERT INTO table1 (id, name, weight, enabled) VALUES ($1, $2, $3, $4)'.

statement execute: { 1. 'foo'. 75.5. true }.
statement executeBatch: { { 2. 'bar'. 80.25. true }. { 3. 'foobar'. 10.75. false } }.

statement close.

statement := client prepare: 'SELECT id, name, weight FROM table1 WHERE id = $1 AND enabled = $2'.
statement query: { 1. true }.

statement close.
```

Note that prepared statements are server side resources that need to be closed when no longer needed.
Prepared statements exist in the scope of a single session/connection.

Next we start over and do the same insert and query using formatted statements.


```smalltalk
client execute: 'TRUNCATE TABLE table1'.

statement := client format: 'INSERT INTO table1 (id, name, weight, enabled) VALUES ($1, $2, $3, $4)'.

statement execute: { 1. 'foo'. 75.5. true }.
statement executeBatch: { { 2. 'bar'. 80.25. true }. { 3. 'foobar'. 10.75. false } }.

statement := client format: 'SELECT id, name, weight FROM table1 WHERE id = $1 AND enabled = $2'.
statement query: { 1. true }.
```

And finally we clean up.

```smalltalk
client execute: 'DROP TABLE table1'.
client close.
```


## Supported Data Types

P3 supports most common PostgreSQL types. Here are some tables with the details.
As of PostgreSQL 9.6, there are 41 general purpose data types of which 32 are currently implemented.

These are the 32 general purpose data type currently implemented,
with the Pharo class they map to.

Name | Alias | Description | Oid | Class 
-----|-------|-------------|-----|------
bigint | int8 | signed eight-byte integer | 20 | Integer
bigserial | serial8 | autoincrementing eight-byte integer | 20 | Integer
bit [n] | | fixed-length bit string | 1560 | P3FixedBitString
bit varying | varbit | variable-length bit string | 1562 | P3BitString
boolean | bool | logical boolean (true/false) | 16 | Boolean
box | | rectangular box on a plane (upperright, lowerleft) | 603 | P3Box
bytea | | binary data (byte array) | 17 | ByteArray
character [n] | char | fixed-length character string | 1042 | String
character varying | varchar | variable-length character string | 1043 | String
circle | | circle on a plane (center, radius) | 718 | P3Circle
date | | calendar date (year,month,day) | 1082 | Date 
double precision | float8 | double precision floating point number (8 bytes) | 701 | Float
integer | int, int4 | signed four-byte integer | 23 | Integer
interval | | time span | 114 | P3Interval
json | | textual JSON data | 114 | NeoJSONObject
jsonb | | binary JSON data, decomposed | 3802 | NeoJSONObject
line | | infinite line on a plane (ax+by+c=0) | 628 | P3Line
lseg | | line segment on a plane (start,stop) | 601 | P3LineSegment
numeric | decimal | exact number of selectable precision | 1700 | ScaledDecimal
path | | geometric path on a plane (points) | 602 | P3Path
point | | geometric point on a plane (x, y) | 600 | P3Point
polygon | | closed geometric path on a plane (points) | 604 | P3Polygon
real | float4 | single-precision floating point number (4-bytes) | 700 | Float
smallint | int2 | signed two-byte integer | 21 | Integer
smallserial | serial2 | autoincrementing two-byte integer | 21 | Integer
serial | serial4 | autoincrementing four-byte integer | 23 | Integer
text | | variable-length character string | 25 | String
time [ without time zone ] | | time of day (no time zone) | 1083 | Time
time with time zone | timetz | time of day including time zone | 1266 | Time
timestamp [ without time zone ] | | date and time (no time zone) | 1114 | DateAndTime
timestamp with time zone  | timestamptz | date and time includig time zone | 1184 | DateAndTime
uuid | | universal unique identifier | 2950 | UUID

Here are the 9 general purpose data types that are not yet implemented.

Name | Description | Oid
-----|-------------|----
cidr | IPv4 or IPv6 network address | 650
inet | IPv4 or IPv6 host address | 869
macaddr | MAC (Media Access Control) address | 829
money | currency amount | 790
pg_lsn | PostgreSQL Log Sequence Number | 3220
tsquery | text search query | 3615
tsvector | text search document | 3614
txid_snapshot | user-level transaction ID snapshot | 2970
xml | XML data | 142

Additionally, the following 9 common types are also implemented, 
with the Pharo class they map to.

Name | Description | Oid | Class 
-----|-------------|-----|------
oid | object identifier | 26 | Integer 
name | name | 19 | String
bpchar | text | 1042 | String
void | void | 2278 | UndefinedObject
_bool | boolean array | 1000 | Array<Boolean>
_int4  | integer array | 1007 | Array<Integer>
_text |	string	array |	1009 | Array<String>
_varchar | string array | 1015 | Array<String>
_float8 | float array |	1022 | Array<Float>

P3 also supports enums. Each enum definition creates a new type.
You can send #loadEnums to P3Client to create mappings for all visible enums.

When you do a query that results in data of an unknown type you will get an error,
P3 cannot convert typeOid XXX, where XXX is the oid in the pg_type table. 


## Connection and Authentication

P3 connects over the network (TCP) to PostgreSQL and
supports plain (#connect) and TLS/SSL encrypted (#connectSSL) connections.

It is out of the scope of this README to explain how to install and configure
an advanced database like PostgreSQL. There is extensive high quality documentation
available convering all aspect of PostgreSQL, see https://postgresql.org

Out of the box, most PostgreSQL installations do not allow for network connections
from other machines, only for local connections.
Check the listen_addresses directive in postgresql.conf

As for authentication, CleartextPassword, MD5Password and SCRAM-SHA-256 are supported.
This means that SCMCredential, GSS, SSPI are currently not (yet) supported.
An error will be signalled when the server requests an unsupported authentication.

You have to create database users, called roles and give them a password.
In SQL you can do this with CREATE|ALTER ROLE user1 LOGIN PASSWORD 'secret'

Next you have to tell PostgreSQL how network users should authenticate themselves.
This is done by editing pg_hba.conf choosing specific methods,
trust (no password, no authentication), password, md5 and scram-sha-256 work with P3.

Note that for SCRAM-SHA-256 to work, you need to change the password_encryption
directive in postgresql.conf to scam-sha-256, restart and reenter all user passwords.


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

**P3ClientTest** holds unit tests for the P3 PSQL client.

Configure it by setting its class side's connection URL.

```smalltalk
P3ClientTest url: 'psql://sven:secret@localhost:5432/database'.
```

The minimal being the following:

```smalltalk
P3ClientTest url: 'psql://sven@localhost'.
```


## Logging

P3 uses object logging, an advanced form of code instrumentation.
This means that during execution instances of subclasses of P3LogEvent
are created (some including timing information)
and sent to an Announcer (accessible via P3LogEvent announcer).
Interested parties can subscribe to these log events
and use the information contained in them
to learn about P3 code execution.

The standard print method of a P3LogEvent can be used to generate textual output.
The following expression enables logging to the Transcript.

```smalltalk
P3LogEvent logToTranscript.
```

Executing the four expressions of the Basic Usage section yields the following output.

```
2020-09-21 16:27:57 001 [P3] 63731 #Connect sven@localhost:5432 Trust
2020-09-21 16:27:57 002 [P3] 63731 #Query SELECT 565 AS N
2020-09-21 16:27:57 003 [P3] 63731 #Result SELECT 1, 1 record, 1 colum, 4 ms
2020-09-21 16:27:57 004 [P3] 63731 #Close

2020-09-21 16:28:07 005 [P3] 63733 #Connect sven@localhost:5432 Trust
2020-09-21 16:28:07 006 [P3] 63733 #Query DROP TABLE IF EXISTS table1
2020-09-21 16:28:07 007 [P3] 63733 #Error P3Notification PostgreSQL table "table1" does not exist, skipping
2020-09-21 16:28:07 008 [P3] 63733 #Result DROP TABLE, 6 ms
2020-09-21 16:28:07 009 [P3] 63733 #Query CREATE TABLE table1 (id INTEGER, name TEXT, enabled BOOLEAN)
2020-09-21 16:28:07 010 [P3] 63733 #Result CREATE TABLE, 50 ms
2020-09-21 16:28:07 011 [P3] 63733 #Query INSERT INTO table1 (id, name, enabled) VALUES (1, 'foo', true)
2020-09-21 16:28:07 012 [P3] 63733 #Result INSERT 0 1, 4 ms
2020-09-21 16:28:07 013 [P3] 63733 #Query INSERT INTO table1 (id, name, enabled) VALUES (2, 'bar', false)
2020-09-21 16:28:07 014 [P3] 63733 #Result INSERT 0 1, 0 ms
2020-09-21 16:28:07 015 [P3] 63733 #Close

2020-09-21 16:28:20 016 [P3] 63737 #Connect sven@localhost:5432 Trust
2020-09-21 16:28:20 017 [P3] 63737 #Query SELECT * FROM table1
2020-09-21 16:28:20 018 [P3] 63737 #Result SELECT 2, 2 records, 3 colums, 2 ms
2020-09-21 16:28:20 019 [P3] 63737 #Close

2020-09-21 16:39:52 020 [P3] 63801 #Connect sven@localhost:5432 Trust
2020-09-21 16:39:52 021 [P3] 63801 #Query DROP TABLE table1
2020-09-21 16:39:52 022 [P3] 63801 #Result DROP TABLE, 13 ms
2020-09-21 16:39:52 023 [P3] 63801 #Close
```

Remember that the information inside the log events can be used to build other applications.


## Development, Goals, Contributing

The main goal of P3 is to be a modern, lean and mean PostgreSQL client for Pharo.
Right now, P3 is functional and usable.

The quality of open source software is determined by it being alive, supported and maintained.

The first way to help is to simply use P3 in your projects and tells us about 
your successes and the issues that you encounter. 
You can ask questions on the Pharo mailing lists.

Development happens on GitHub, where you can create issues.

Contributions should be done with pull requests solving specific issues.
