private
processParameterStatus: payload
	"Do not yet use the converter since it is not yet initialized"
	
	properties 
		at: (self converter asciiCStringFrom: payload)
		put: (self converter asciiCStringFrom: payload)