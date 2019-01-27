Extension { #name : #ByteArray }

{ #category : #'*P3' }
ByteArray >> p3PrintUsing: delegate on: stream [
	"Print me on stream via double dispatch on delegate.
	Check the implementors of #p3PrintOn:using:"

	delegate printByteArray: self on: stream
]

{ #category : #'*P3' }
ByteArray >> printAsP3TextOn: aStream [
	"Append to the argument aStream a representation of the receiver in 
	Postgres text format"

	| v map |

	aStream
		nextPut: $\;
		nextPut: $x.
	map := '0123456789abcdef'.
	1 to: self size do: [ :i |
		v := self at: i.
		aStream 
			nextPut: (map at: (v bitShift: -4) + 1);
			nextPut: (map at: (v bitAnd: 15) + 1) ]
]
