converting
convertDateAndTimeFrom: bytes length: length description: description
	"TIMESTAMP WITH TIME ZONE (TIMESTAMPTZ) is stored internally in Postgres as UTC, but represented in the timezone of the connection, with a correct offset added. In other words, Postgres does the necessary shifting, we just have to read the result"
	
	^ DateAndTime readFrom: (self asciiStreamFor: bytes length: length)