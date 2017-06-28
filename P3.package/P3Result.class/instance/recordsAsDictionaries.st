convenience
recordsAsDictionaries
	^ self records collect: [ :record |
		| dictionary |
		dictionary := Dictionary new.
		self descriptions withIndexDo: [ :description :index |
			dictionary at: description fieldName asSymbol put: (record at: index) ].
		dictionary ]