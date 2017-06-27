protocol
runQueryResult
	| description data result |
	description := data := result := nil.
	self readMessage tag = $T
		ifTrue: [ description := self processRowDescription: message readStream ].
	message tag = $C ifFalse: [ 
		data := Array streamContents: [ :out |
			[ self readMessage tag = $C ] whileFalse: [ 
				self assert: message tag = $D.
				out nextPut: (self processDataRowUsing: description) ] ] ].
	[ | subResult |
		subResult := (self converter asciiCStringFrom: message readStream).
		result := self extendResult: result with: subResult.
		self readMessage tag = $Z ] whileFalse.
	^ { result. description. data }