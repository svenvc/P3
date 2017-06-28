I am P3DatabaseDriver, a Glorp Database Driver using the P3Client for PostgreSQL.

Installation

  PharoDatabaseAccessor DefaultDriver: P3DatabaseDriver.

Configure your session using a Glorp Login object

  Login new
    database: PostgreSQLPlatform new;
    username: 'username';
    password: 'password';
    connectString: 'host:5432_databasename';
    encodingStrategy: #utf8;
    yourself.