public
query: query
	"Execute an SQL query against PostgreSQL. Return a triplet { result. descriptions. data }.
	Result is a string (collection of strings for multiple embedded queries) indicating successful execution.
	Descriptions is a collection of row field description objects.
	Data is a collection of rows with fully converted field values as objects."

	^ self 
		ensureConnected;
		writeQueryMessage: query;
		runQueryResult