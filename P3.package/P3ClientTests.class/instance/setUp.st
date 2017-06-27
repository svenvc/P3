running
setUp
	client := P3Client new.
	url ifNil: [ self error: 'You have to specify a connection URL (see my class comment)' ].
	client url: url.
	client connect