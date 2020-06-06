Class {
	#name : #Utils,
	#superclass : #Object,
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
Utils class >> easyJoinArray: inStringArray [
	"translates a Array<String> into a return delimited string body"

	| b |
	b := String new writeStream.
	inStringArray
		do: [ :curr | b nextPutAll: curr ]
		separatedBy: [ b
				nextPutAll:
					'
' ].
	^ b contents
]
