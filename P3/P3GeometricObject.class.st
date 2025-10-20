"
I am P3GeometricObject, the abstract superclass for all PostgreSQL geometric data types, 
representing two-dimensional spatial objects.
"
Class {
	#name : 'P3GeometricObject',
	#superclass : 'Object',
	#category : 'P3-Objects',
	#package : 'P3',
	#tag : 'Objects'
}

{ #category : 'accessing' }
P3GeometricObject class >> tag [
	self subclassResponsibility
]

{ #category : 'printing' }
P3GeometricObject >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintUsing:on:"

	delegate printGeometricObject: self on: stream
]

{ #category : 'printing' }
P3GeometricObject >> printPsqlOn: stream [
	stream 
		nextPutAll: self tag; 
		space; 
		nextPut: $'; 
		print: self; 
		nextPut: $'
]

{ #category : 'accessing' }
P3GeometricObject >> tag [
	^ self class tag
]
