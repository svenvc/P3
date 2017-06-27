private
extendResult: result with: subResult
	^ result 
			ifNil: [ 
				subResult ] 
			ifNotNil: [ 
				result isString 
					ifTrue: [ Array with: result with: subResult ] 
					ifFalse: [ result copyWith: subResult ] ]