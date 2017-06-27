initialization
initializeForSize: actualSize
	(payload isNil or: [ actualSize > self capacity ])
		ifTrue: [ payload := (ByteArray new: ((actualSize // 1024) + 1) * 1024) readStream ].
	size := actualSize.
	payload setFrom: 1 to: size