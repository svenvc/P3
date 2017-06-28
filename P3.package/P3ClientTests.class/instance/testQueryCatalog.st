testing
testQueryCatalog
	| result |
	result := client query: 'SELECT schemaname,tablename FROM pg_catalog.pg_tables'.
	"there are two columns"
	self assert: result numberOfColumns equals: 2.
	"this was a select"
	self assert: ($ split: result firstResult) first equals: 'SELECT'.
	"the select returned a count for the number of dataRows"
	self assert: result rowCount equals: result numberOfRecords.
	"each dataRow has two fields"
	self assert: (result data allSatisfy: [ :each | each size = 2])