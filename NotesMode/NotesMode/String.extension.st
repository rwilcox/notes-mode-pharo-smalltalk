Extension { #name : 'String' }

{ #category : '*NotesMode' }
String >> indexCorrespendingToLineNumber: lineNum [
	"comment stating purpose of message"

	| currLineNumber foundStartDelim foundEndDelim|
	
	currLineNumber := 1.
	foundStartDelim := 0.
	foundEndDelim := 0.
	
	self lineIndicesDo: [ :startIndex :stopIndex :stopIndexIncLineDelim |
			(lineNum  = currLineNumber ) ifTrue: [ 
				foundStartDelim := startIndex.
				foundEndDelim := stopIndex.
			].
			currLineNumber := currLineNumber + 1.
  ].
^ Array with: foundStartDelim with: foundEndDelim .
]
