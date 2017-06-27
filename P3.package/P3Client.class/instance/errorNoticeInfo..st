private
errorNoticeInfo: payload
	| info fieldType |
	info := Dictionary new.
	[ (fieldType := payload next) isZero ] 
		whileFalse: [ 
			info 
				at: fieldType asCharacter 
				put: (self converter asciiCStringFrom: payload) ].
	^ info