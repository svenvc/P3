I am P3Result, I encapsulate the result from a PostgreSQL query.

I hold 3 things:

- results -  the command completion tags, a String (singular if there was only one query) or a collection ofStrings (if there were multiple queries) in the form of 'SELECT 100'

- descriptions - a collection of P3RowFieldDescription objects (one for each column, nil if there is no data)

- data - a collection of records with each field value converted to objects, nil if there is no data

Even if there are multiple queries, there can only be one stream of records. Most of the time, results is singular.