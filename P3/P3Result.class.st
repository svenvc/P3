"
I am P3Result, I encapsulate the result from a PostgreSQL query.

I hold 3 things:

- results -  the command completion tags, a String (singular if there was only one query) or a collection ofStrings (if there were multiple queries) in the form of 'SELECT 100'

- descriptions - a collection of P3RowFieldDescription objects (one for each column, nil if there is no data)

- data - a collection of records with each field value converted to objects, nil if there is no data

Even if there are multiple queries, there can only be one stream of records. Most of the time, results is singular.
"
Class {
	#name : #P3Result,
	#superclass : #Object,
	#instVars : [
		'results',
		'descriptions',
		'data'
	],
	#category : 'P3'
}

{ #category : #'instance creation' }
P3Result class >> descriptions: descriptions rows: aRowArray message: aString [

	^ self new
			descriptions: descriptions;
			data: aRowArray;
			results: aString;
			yourself
]

{ #category : #accessing }
P3Result >> addResult: subResult [
	results := results
		ifNil: [ subResult ]
		ifNotNil: [ results isString
				ifTrue: [ Array with: results with: subResult ]
				ifFalse: [ results copyWith: subResult ] ]
]

{ #category : #convenience }
P3Result >> columnNames [
	^ descriptions collect: #fieldName
]

{ #category : #convenience }
P3Result >> columns [
	^ descriptions
]

{ #category : #accessing }
P3Result >> data [
	^ data
]

{ #category : #accessing }
P3Result >> data: collection [
	data := collection
]

{ #category : #accessing }
P3Result >> descriptions [
	^ descriptions
]

{ #category : #accessing }
P3Result >> descriptions: collectionOfRowFieldDescriptions [
	descriptions := collectionOfRowFieldDescriptions
]

{ #category : #convenience }
P3Result >> firstFieldOfFirstRecord [
	^ self firstRecord first
]

{ #category : #accessing }
P3Result >> firstRecord [
	^ self records first
]

{ #category : #accessing }
P3Result >> firstResult [
	^ results isString ifTrue: [ results ] ifFalse: [ results first ]
]

{ #category : #accessing }
P3Result >> firstRowCount [
	^ self rowCountFromCommandResultTag: self firstResult
]

{ #category : #testing }
P3Result >> hasData [
	^ data notNil
]

{ #category : #testing }
P3Result >> hasDescriptions [
	^ descriptions notNil
]

{ #category : #testing }
P3Result >> hasResults [
	^ results notNil
]

{ #category : #accessing }
P3Result >> numberOfColumns [
	^ self hasDescriptions ifTrue: [ self descriptions size ] ifFalse: [ 0 ]
]

{ #category : #accessing }
P3Result >> numberOfRecords [
	^ self hasData ifTrue: [ self data size ] ifFalse: [ 0 ]
]

{ #category : #printing }
P3Result >> printOn: stream [
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
]

{ #category : #convenience }
P3Result >> records [
	^ data
]

{ #category : #convenience }
P3Result >> recordsAsDictionaries [
	^ self records collect: [ :record |
		| dictionary |
		dictionary := Dictionary new.
		self descriptions withIndexDo: [ :description :index |
			dictionary at: description fieldName asSymbol put: (record at: index) ].
		dictionary ]
]

{ #category : #accessing }
P3Result >> result [
	^ self firstResult
]

{ #category : #accessing }
P3Result >> results [
	^ results
]

{ #category : #accessing }
P3Result >> results: stringOrCollectionOfStrings [
	results := stringOrCollectionOfStrings
]

{ #category : #accessing }
P3Result >> rowCount [
	^ self firstRowCount
]

{ #category : #private }
P3Result >> rowCountFromCommandResultTag: string [
	^ ($ split: string) last asInteger
]

{ #category : #accessing }
P3Result >> totalRowCount [
	results ifNil: [ ^ 0 ].
	^ results isString
		ifTrue: [ self firstRowCount ]
		ifFalse: [ results inject: 0 into: [ :sum :next | sum + (self rowCountFromCommandResultTag: next) ] ]
]
