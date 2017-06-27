accessing
typeName
	^ (P3Converter typeMap at: self typeOid ifAbsent: [ ^ self typeOid ]) first