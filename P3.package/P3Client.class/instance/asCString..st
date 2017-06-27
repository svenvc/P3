private
asCString: string
	| bytes |
	bytes := ByteArray new: string size + 1.
	"implicit cheap ASCII conversion"
	bytes replaceFrom: 1 to: string size with: string startingAt: 1. 
	"last byte is 0"
	^ bytes