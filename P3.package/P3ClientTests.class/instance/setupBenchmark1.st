benchmarking
setupBenchmark1
	| timeToRun |
	self setUp. 
	timeToRun := [
		client query: 'DROP TABLE IF EXISTS benchmark1'.
		client query: 'CREATE TABLE benchmark1 (n_int INTEGER, n_float FLOAT, hex TEXT, roman TEXT, words TEXT)'.
		1 to: self benchmark1Size do: [ :n |
			| sql |
			sql := 'INSERT INTO benchmark1 (n_int, n_float, hex, roman, words) VALUES ({1}, {2}, ''{3}'', ''{4}'', ''{5}'')' 
				format: { n. Float pi * n. n printStringHex. n printStringRoman.  n asWords }.
			client query: sql ] ] timeToRun.
	self tearDown.
	^ timeToRun  