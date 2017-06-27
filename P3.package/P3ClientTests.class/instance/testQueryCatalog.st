testing
testQueryCatalog
	| result count |
	result := client query: 'SELECT schemaname,tablename FROM pg_catalog.pg_tables'.
	"triplet #(result rowFieldDescriptions dataRows)"
	self assert: result size equals: 3.
	"there are two columns"
	self assert: result second size equals: 2.
	"this was a select"
	self assert: ($ split: result first) first equals: 'SELECT'.
	"the select returned a count for the number of dataRows"
	count := ($ split: result first) second asInteger.
	self assert: result third size equals: count.
	"each dataRow has two fields"
	self assert: (result third allSatisfy: [ :each | each size = 2])