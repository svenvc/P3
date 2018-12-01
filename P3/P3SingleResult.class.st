Class {
	#name : #P3SingleResult,
	#superclass : #P3Result,
	#category : #P3
}

{ #category : #'instance creation' }
P3SingleResult class >> descriptions: descriptions rows: aRowArray message: aString [

	^ self new
			descriptions: descriptions;
			data: aRowArray;
			results: aString;
			yourself
]
