private
processRowDescription: payload
	| count |
	count := payload uint16.
	^ Array new: count streamContents: [ :out |
			count timesRepeat: [ 
				out nextPut: (P3RowFieldDescription new
					fieldName: (self converter encodedCStringFrom: payload);
					tableOid: payload uint32;
					attributeNumber: payload uint16;
					typeOid: payload uint32;
					typeSize: payload uint16;
					typeModifier: payload uint32;
					format: payload uint16;
					yourself) ] ]