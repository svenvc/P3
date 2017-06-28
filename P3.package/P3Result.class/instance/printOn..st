printing
printOn: stream
	super printOn: stream.
	stream nextPut: $(.
	self hasResults
		ifTrue: [ stream print: results ].
	self hasData
		ifTrue: [ stream
				space;
				print: self numberOfRecords;
				<< (' record' asPluralBasedOn: self numberOfRecords);
				space;
				print: self numberOfColumns;
				<< (' colum' asPluralBasedOn: self numberOfColumns) ].
	stream nextPut: $)