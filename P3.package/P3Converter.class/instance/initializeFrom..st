initalize
initializeFrom: properties
	| serverTimezone serverEncoder |
	serverTimezone := properties at: 'TimeZone' ifAbsent: [ 'GMT' ].
	serverTimezone := ZTimezone id: serverTimezone.
	self timezone: serverTimezone.
	serverEncoder := properties at: 'client_encoding' ifAbsent: [ 'UTF8' ].
	serverEncoder := ZnCharacterEncoder newForEncoding: serverEncoder.
	self encoder: serverEncoder