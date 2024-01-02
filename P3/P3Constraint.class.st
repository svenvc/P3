"
I am P3Constraint.
I am an abstract class.

I represent an SQL constraint.

I have
- a name
- a schem:table that I am defined on
- a list of columns on which I am applicable

I can reproduce my SQL definition.

Use me to get all constraints for a given table.

My concrete subclasses implement actual constraint types. 
"
Class {
	#name : #P3Constraint,
	#superclass : #Object,
	#instVars : [
		'constraintSchema',
		'constraintName',
		'tableSchema',
		'tableName',
		'isDeferrable',
		'initiallyDeferred',
		'enforced',
		'constraintColumns'
	],
	#category : #'P3-Support'
}

{ #category : #accessing }
P3Constraint class >> allForTable: tableName in: schemaName using: client [
	| statement result specificClass constraint |
	statement := client format: 'SELECT constraint_schema, constraint_name, constraint_type, is_deferrable, initially_deferred, enforced FROM information_schema.table_constraints WHERE table_schema = $1 AND table_name= $2'.
	result := statement query: { schemaName . tableName }.
	^ result data collect: [ :row |
		specificClass := self subclasses 
							detect: [ :each | each handlesType: row third ] 
							ifNone: [ self error: 'unknown contraint type' ].
		constraint := specificClass new.
		constraint
			tableSchema: schemaName;
			tableName: tableName;
			constraintSchema: row first;
			constraintName: row second;
			isDeferrable: row fourth = 'YES';
			initiallyDeferred: row fifth = 'YES';
			enforced: row = 'YES'.
		constraint loadDetailsUsing: client.
		constraint ]
]

{ #category : #accessing }
P3Constraint class >> handlesType: type [
	self subclassResponsibility
]

{ #category : #accessing }
P3Constraint class >> referencingConstraintNamesForTable: tableName in: schemaName using: client [
	"Return (table_name, constraint_name) pairs where the given schemaName:tableName is referenced.
	Do not return the actual constraint object as this might be costly to compute."

	| statement result |
	statement := client format: 'SELECT tc.table_name, ctu.constraint_name
FROM information_schema.constraint_table_usage AS ctu, information_schema.table_constraints AS tc
WHERE ctu.table_schema = $1 AND ctu.table_name = $2 AND ctu.constraint_name = tc.constraint_name AND tc.constraint_type = ''FOREIGN KEY'''.
	result := statement query: { schemaName . tableName }.
	^ result data
]

{ #category : #accessing }
P3Constraint >> constraintColumns [
	^ constraintColumns
]

{ #category : #accessing }
P3Constraint >> constraintColumns: anObject [
	constraintColumns := anObject
]

{ #category : #accessing }
P3Constraint >> constraintName [
	^ constraintName
]

{ #category : #accessing }
P3Constraint >> constraintName: anObject [
	constraintName := anObject
]

{ #category : #accessing }
P3Constraint >> constraintSchema [
	^ constraintSchema
]

{ #category : #accessing }
P3Constraint >> constraintSchema: anObject [
	constraintSchema := anObject
]

{ #category : #accessing }
P3Constraint >> constraintType [
	self subclassResponsibility
]

{ #category : #accessing }
P3Constraint >> enforced [
	^ enforced
]

{ #category : #accessing }
P3Constraint >> enforced: anObject [
	enforced := anObject
]

{ #category : #accessing }
P3Constraint >> initiallyDeferred [
	^ initiallyDeferred
]

{ #category : #accessing }
P3Constraint >> initiallyDeferred: anObject [
	initiallyDeferred := anObject
]

{ #category : #testing }
P3Constraint >> isCheck [
	^ self constraintType = 'CHECK'
]

{ #category : #accessing }
P3Constraint >> isDeferrable [
	^ isDeferrable
]

{ #category : #accessing }
P3Constraint >> isDeferrable: anObject [
	isDeferrable := anObject
]

{ #category : #testing }
P3Constraint >> isForeignKey [
	^ self constraintType = 'FOREIGN KEY'
]

{ #category : #testing }
P3Constraint >> isPrimaryKey [
	^ self constraintType = 'PRIMARY KEY'
]

{ #category : #testing }
P3Constraint >> isUnique [
	^ self constraintType = 'UNIQUE'
]

{ #category : #accessing }
P3Constraint >> loadDetailsUsing: client [
	| statement result |
	statement := client format: 'SELECT column_name FROM information_schema.key_column_usage WHERE constraint_schema = $1 AND constraint_name = $2'.
	result := statement query: { self constraintSchema . self constraintName }.
	self constraintColumns: result firstColumnData
]

{ #category : #accessing }
P3Constraint >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(. 
	self constraintName ifNotNil: [ :name | 
		stream nextPutAll: name ]. 
	self sqlDescription ifNotNil: [ :description |
		self constraintName ifNotNil: [ stream space ].
		stream nextPutAll: description ].
	stream nextPut: $)
]

{ #category : #accessing }
P3Constraint >> sqlDescription [
	self subclassResponsibility
]

{ #category : #accessing }
P3Constraint >> tableName [
	^ tableName
]

{ #category : #accessing }
P3Constraint >> tableName: anObject [
	tableName := anObject
]

{ #category : #accessing }
P3Constraint >> tableSchema [
	^ tableSchema
]

{ #category : #accessing }
P3Constraint >> tableSchema: anObject [
	tableSchema := anObject
]
