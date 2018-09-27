P3ClientTests holds unit tests for the P3 PSQL client.

Configure by setting my class side's connection URL.

  P3ClientTests url: 'psql://sven:secret@localhost:5432/database'.

The minimal being the following:

  P3ClientTests url: 'psql://sven@localhost'.

Benchmarks

  P3ClientTests new setupBenchmark1.
  P3ClientTests new runBenchmark1.
  P3ClientTests new runBenchmark1Bench.
  P3ClientTests new runAllTests.