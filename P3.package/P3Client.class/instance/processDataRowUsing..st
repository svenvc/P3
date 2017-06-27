private
processDataRowUsing: description
	| count record readStream |
	readStream := message readStream.
	count := readStream uint16.
	record := Array new: count.
	1 to: count do: [ :index | | size |
		size := readStream uint32.
		size = 16rFFFFFFFF
			ifFalse: [ | object |
				object := (description at: index) convert: readStream length: size using: converter.
				record at: index put: object ] ].
	^ record