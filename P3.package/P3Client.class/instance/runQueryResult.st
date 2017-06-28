protocol
runQueryResult
	| result |
	result := P3Result new.
	self readMessage tag = $T
		ifTrue: [ result descriptions: (self processRowDescription: message readStream) ].
	message tag = $C ifFalse: [ 
		result data: (Array streamContents: [ :out |
			[ self readMessage tag = $C ] whileFalse: [ 
				self assert: message tag = $D.
				out nextPut: (self processDataRowUsing: result descriptions) ] ]) ].
	[
		result addResult: (self converter asciiCStringFrom: message readStream).
		self readMessage tag = $Z ] whileFalse.
	^ result