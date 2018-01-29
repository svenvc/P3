private
processParameterStatus: payload
	"Do not yet use the converter since it is not yet initialized"
	
	| key value |
	
	key := self converter asciiCStringFrom: payload.
	value := self converter asciiCStringFrom: payload.
		
	properties at: key put: value