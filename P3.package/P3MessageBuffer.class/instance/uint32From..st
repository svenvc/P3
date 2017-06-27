reading
uint32From: stream
	| uint32 |
	uint32 := stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	uint32 := (uint32 bitShift: 8) + stream next.
	^ uint32