converting
convertDateAndTimeWithoutTimezoneFrom: bytes length: length description: description
	"TIMESTAMP WITHOUT TIME ZONE (TIMESTAMP) is stored internally in Postgres the way it was inserted, its representation remains constant, with no offset added. We use the timezone of the connection to do the necessary shifting. This assumes that the timezones used during insert/update and query are the same."

	| timestamp offset |
	timestamp := DateAndTime readFrom: (self asciiStreamFor: bytes length: length) defaultOffset: Duration zero.
	offset := self timezone offsetForTimestamp: timestamp.
	^ timestamp translateTo: offset