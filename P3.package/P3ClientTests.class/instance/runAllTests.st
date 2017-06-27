benchmarking
runAllTests
	"Runs all tests on the same connection/session"
	
	| testSelectors timeToRun |
	testSelectors := self class selectors select: [ :each | 'test*' match: each ].
	self setUp.
	timeToRun := [ testSelectors do: [ :each | self perform: each ] ] timeToRun.
	self tearDown.
	^ timeToRun 