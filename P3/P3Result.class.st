"
I am P3Result, I encapsulate the result from a PostgreSQL query.

I hold 3 things:

- results -  the command completion tags, a String (singular if there was only one query) or a collection of Strings (if there were multiple queries) in the form of 'SELECT 100'

- descriptions - a collection of P3RowFieldDescription objects (one for each column, nil if there is no data)

- data - a collection of records with each field value converted to objects, nil if there is no data

Even if there are multiple queries, there can only be one stream of records. Most of the time, results is singular.
In the case of multiple queries, there will be multiple results (an array of results), one for each query. However, only the last record stream will be in the data and descriptions.
"
Class {
	#name : #P3Result,
	#superclass : #Object,
	#instVars : [
		'results',
		'descriptions',
		'data'
	],
	#category : #'P3-Core'
}

{ #category : #'instance creation' }
P3Result class >> descriptions: descriptions rows: aRowArray message: aString [

	^ self new
			descriptions: descriptions;
			data: aRowArray;
			results: aString;
			yourself
]

{ #category : #'private-accessing' }
P3Result >> addResult: subResult [
	results := results
		ifNil: [ subResult ]
		ifNotNil: [ results isString
				ifTrue: [ Array with: results with: subResult ]
				ifFalse: [ results copyWith: subResult ] ]
]

{ #category : #convenience }
P3Result >> columnNames [
	"Return the names of the columns of the data that I hold"
	
	^ descriptions collect: #fieldName
]

{ #category : #convenience }
P3Result >> columns [
	"Return the P3RowFieldDescriptions of the columns of the data that I hold"

	^ descriptions
]

{ #category : #accessing }
P3Result >> data [
	"Return the data that I represent, 
	an Array containing equal sized Arrays for each record in the result"
	
	^ data
]

{ #category : #'private-accessing' }
P3Result >> data: collection [
	data := collection
]

{ #category : #accessing }
P3Result >> descriptions [
	"Return the P3RowFieldDescriptions of the result that I represent.
	There will be one such description for each column."
	
	^ descriptions
]

{ #category : #'private-accessing' }
P3Result >> descriptions: collectionOfRowFieldDescriptions [
	descriptions := collectionOfRowFieldDescriptions
]

{ #category : #convenience }
P3Result >> firstColumnData [
	"Return a flat collection of the data in the first column that I hold"
	
	^ data collect: #first
]

{ #category : #convenience }
P3Result >> firstFieldOfFirstRecord [
	"Return the value of the first field of the first record that I hold"
	
	^ self firstRecord first
]

{ #category : #accessing }
P3Result >> firstRecord [
	"Return the first record of the result, which will be an Array"
	
	^ self records first
]

{ #category : #accessing }
P3Result >> firstResult [
	"Return the SQL query execution result, or the first one if there are multiple results.
	Among other things, the result indicates how many rows were returned or modified."
	
	^ results isString ifTrue: [ results ] ifFalse: [ results first ]
]

{ #category : #accessing }
P3Result >> firstRowCount [
	"Return the row count for the first result that I hold.
	This is the integer count of the the number of records returned or modified"
	
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
P3Result >> lastResult [
	"Return the SQL query execution result, or the last one if there are multiple results.
	Among other things, the result indicates how many rows were returned or modified."
	
	^ results isString ifTrue: [ results ] ifFalse: [ results last ]
]

{ #category : #accessing }
P3Result >> numberOfColumns [
	"Return the number of columns that I hold.
	Each record in my data will be of this size."
	
	^ self hasDescriptions ifTrue: [ self descriptions size ] ifFalse: [ 0 ]
]

{ #category : #accessing }
P3Result >> numberOfRecords [
	"Return the actual number of records that are in the data that I hold.
	In principle this equals #rowCount"
	
	^ self hasData ifTrue: [ self data size ] ifFalse: [ 0 ]
]

{ #category : #printing }
P3Result >> printInfoOn: stream [
	self hasResults
		ifTrue: [ 
			results isString
				ifTrue: [ stream nextPutAll: results ]
				ifFalse: [ 
					results 
						do: [ :each | stream nextPutAll: each ]
						separatedBy: [ stream << ', ' ] ] ].
	(self hasData and: [ self data notEmpty ])
		ifTrue: [ 
			stream
				<< ', ';
				print: self numberOfRecords;
				<< (' record' asPluralBasedOn: self numberOfRecords);
				<< ', ';
				print: self numberOfColumns;
				<< (' colum' asPluralBasedOn: self numberOfColumns) ]
]

{ #category : #printing }
P3Result >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self printInfoOn: stream.
	stream nextPut: $)
]

{ #category : #convenience }
P3Result >> records [
	"Return the records that I hold, also known as my data"
	
	^ data
]

{ #category : #convenience }
P3Result >> recordsAsDictionaries [
	"Return the data that I hold as a collection where each record 
	is represented by a Dictionary whose keys are the column names.
	This more verbose representation can be more user friendly."
	
	^ self records collect: [ :record |
		| dictionary |
		dictionary := Dictionary new.
		self descriptions withIndexDo: [ :description :index |
			dictionary at: description fieldName asSymbol put: (record at: index) ].
		dictionary ]
]

{ #category : #accessing }
P3Result >> result [
	"Return the result.
	As this is the most common case, we assume a single result."
	
	^ self firstResult
]

{ #category : #accessing }
P3Result >> results [
	"Return the SQL query execution results, possibly a collection.
	Among other things, the results indicates how many rows were returned or modified."

	^ results
]

{ #category : #'private-accessing' }
P3Result >> results: stringOrCollectionOfStrings [
	results := stringOrCollectionOfStrings
]

{ #category : #accessing }
P3Result >> rowCount [
	"Return the integer count of the number of records returned or modified.
	If there is data, this equals #numberOfRecords"
	
	^ self firstRowCount
]

{ #category : #private }
P3Result >> rowCountFromCommandResultTag: string [

	string ifEmpty: [ ^ 0 ].
	^ ($ split: string) last asInteger
]

{ #category : #accessing }
P3Result >> totalRowCount [
	"Return the total integer count of the number of record returned or modified in all results"

	results ifNil: [ ^ 0 ].
	^ results isString
		ifTrue: [ 
			self firstRowCount ]
		ifFalse: [ 
			results 
				inject: 0 
				into: [ :sum :next | sum + (self rowCountFromCommandResultTag: next) ] ]
]
