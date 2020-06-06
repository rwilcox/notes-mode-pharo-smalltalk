Class {
	#name : #DiaryFileHelper,
	#superclass : #Object,
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
DiaryFileHelper class >> readDiaryFileAsStream: stringPath implicitEntityKind: entityKind [
	| a lineStream output |
	lineStream := LineByLineStream new.
	lineStream stream: stringPath asFileReference readStream.
	a := NotesModeFileParser new.
	output := QueryMatches new.
	output matches: (a matchesForImplicitWikiWordsFromStreamItems: lineStream).
	^ output
]

{ #category : #'as yet unclassified' }
DiaryFileHelper class >> readDiaryFileAsStream: stringPath itemKind: kind excludeCompleted: completed [
	"like readDiaryFileAs"

	| a lineStream output |
	lineStream := LineByLineStream new.
	lineStream stream: stringPath asFileReference readStream.
	a := NotesModeFileParser new.
	
	output := QueryMatches new.
	output matches: (a matchesForStreamItems: lineStream matchingKind: kind excludeCompleted: completed).
	^ output.
]
