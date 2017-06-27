private
asciiStreamFor: bytes length: length
	| asciiString |
	asciiString := asciiReadStream originalContents.
	asciiString size < length
		ifTrue: [ 
			asciiReadStream := (asciiString := String new: ((length // 64) + 1) * 64) readStream ].
	bytes next: length into: asciiString. "implicit cheap ASCII conversion"
	asciiReadStream setFrom: 1 to: length.
	^ asciiReadStream 