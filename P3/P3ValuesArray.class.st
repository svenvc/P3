"
I am P3ValuesArray.

I hold a list of database values that are rendered recursively as an array of values.

I am a helper object used for statement construction.

The following example shows a technique to use parameters for 'IN (...)' using '= ANY'.

statement := client prepare: 'SELECT * FROM my_table WHERE id = ANY ($1)'.
statement query: { P3ValuesArray withAll: #(1 2) }.

statement := client format: 'SELECT * FROM fmi_owner WHERE id = ANY ($1)'.
statement query: { P3ValuesArray withAll: #(1 2) }.

"
Class {
	#name : 'P3ValuesArray',
	#superclass : 'Object',
	#instVars : [
		'array'
	],
	#category : 'P3-Objects',
	#package : 'P3',
	#tag : 'Objects'
}

{ #category : 'requirements' }
P3ValuesArray class >> empty [
	^ self withAll: #()
]

{ #category : 'instance creation' }
P3ValuesArray class >> withAll: collection [
	^ self new
		values: collection asArray;
		yourself
]

{ #category : 'enumerating' }
P3ValuesArray >> do: block [
	array do: block
]

{ #category : 'testing' }
P3ValuesArray >> isEmpty [
	^ array isNil or: [ array isEmpty ]
]

{ #category : 'printing' }
P3ValuesArray >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printValuesArray: self on: stream
]

{ #category : 'accessing' }
P3ValuesArray >> size [
	^ array ifNil: [ 0 ] ifNotNil: [ array size ]
]

{ #category : 'accessing' }
P3ValuesArray >> values [
	^ array
]

{ #category : 'accessing' }
P3ValuesArray >> values: anArray [
	array := anArray
]
