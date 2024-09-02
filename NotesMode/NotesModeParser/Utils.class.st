Class {
	#name : #Utils,
	#superclass : #Object,
	#category : #NotesModeParser
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

{ #category : #'as yet unclassified' }
Utils class >> tagStringFromLine: line [
	"comment stating purpose of message"

  |r output|

  r := '.+ =\[(.+)\]' asRegex.

  (r matches: line) ifTrue: [.
  	output := r subexpression: 2.
  ].

  ^ output.
]
