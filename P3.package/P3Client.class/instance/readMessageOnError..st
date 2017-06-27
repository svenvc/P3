input/output
readMessageOnError: block
	message readFrom: connection.
	message tag = $E 
		ifTrue: [ | info |
			info := self errorNoticeInfo: message readStream.
			block cull: info.
			self signal: P3Error using: info ].
	message tag = $N 
		ifTrue: [ | info |
			info := self errorNoticeInfo: message readStream.
			self signal: P3Notification using: info.
			^ self readMessage ].
	^ message