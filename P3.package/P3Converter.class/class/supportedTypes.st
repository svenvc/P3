accessing
supportedTypes
	"Return the list of PostgreSQL internal type names that we can convert to objects."
	
	^ self typeMap values collect: #first