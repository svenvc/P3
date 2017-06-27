benchmarking
runBenchmark1Bench
	| result timeToRun |
	result := nil.
	self setUp.
	timeToRun := [ result := client query: 'SELECT * FROM benchmark1' ] benchFor: 5 seconds.
	self assert: result third size equals: self benchmark1Size.
	self tearDown.
	^ timeToRun 