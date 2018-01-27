private
reset
	properties removeAll.
	settings at: #connected put: false.
	converter := nil