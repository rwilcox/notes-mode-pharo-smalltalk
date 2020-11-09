"
Meant to abstract away having one or multiple files in a notes mode project. Provides a bit of an interface over NotesModeFileParser, but taking care of the iteration.
"
Class {
	#name : #NotesModeProjectParser,
	#superclass : #Object,
	#instVars : [
		'inputLines',
		'fileRefsForProject'
	],
	#category : #NotesMode
}

{ #category : #accessing }
NotesModeProjectParser >> fileRefsForProject [
	^ fileRefsForProject
]

{ #category : #accessing }
NotesModeProjectParser >> fileRefsForProject: anObject [
	fileRefsForProject := anObject
]

{ #category : #'multi line items' }
NotesModeProjectParser >> matchesForImplicitDayEntry [
	"returns a dictionary where every key is a Smalltalk Date object and every value a MultilineKindMatch of the text entries made during that date object (aka: until the next one)"

	| groups |
	groups := Dictionary new.
	fileRefsForProject
		do: [ :currentFileRef | 
			| p stream current lastLine |
			lastLine := nil.
			current := nil.
			
			p := NotesModeFileParser new.
			p currentFileReference: currentFileRef.
			stream := LineByLineStream new.
			stream stream: currentFileRef readStream .
			
			stream
				do: [ :each | 
					current := p
						addLineToDateIfRequired: groups
						previousLine: lastLine
						currentLine: each
						currentDate: current.
					lastLine := each ] ].

	^ groups
]

{ #category : #'single line sections' }
NotesModeProjectParser >> matchesForImplicitWikiWords [
	"comment stating purpose of message"

	| output |
	output := OrderedCollection new.
	fileRefsForProject
		do: [ :currentFileRef | 
			| counter p stream |
			
			p := NotesModeFileParser new.
			p currentFileReference: currentFileRef.
			stream := LineByLineStream new.
			stream stream: currentFileRef readStream.
			counter := 1.
			
			stream
				do: [ :each | 
					(p isWikiWordLine: each)
						ifTrue: [ | kindMatch |
							kindMatch := KindMatch new.
							kindMatch
								completed: false;
								kind: 'wikiword';
								lineText: each;
								foundInFileReference: currentFileRef;
								lineNumber: counter.
							output add: kindMatch ].
					counter := counter + 1 ] ].
	^ output
]

{ #category : #'single line sections' }
NotesModeProjectParser >> matchesForMatchingKind: kind excludeCompleted: excludeCompleted [
	| p theStream output counter |
	output := OrderedCollection new.
	fileRefsForProject
		do: [ :currentFileRef | 
			counter := 1.
			p := NotesModeFileParser new.
			p currentFileReference: currentFileRef.
			theStream := LineByLineStream new.
			theStream stream: currentFileRef readStream.
			
			theStream
				do: [ :each | 
					(p isLine: each ofKind: kind excludeCompleted: excludeCompleted)
						ifTrue: [ 
							| kindMatch |
							
							kindMatch := KindMatch new.
							kindMatch
								completed: (p isCompletedItemLine: each forKind: kind) = 1;
								kind: kind;
								lineText: each;
								foundInFileReference: currentFileRef;
								lineNumber: counter.
								
							kindMatch tagsArrayFromString: (Utils tagStringFromLine: each).
							output add: kindMatch ].
					counter := counter + 1 ] 
			].
	^ output
]

{ #category : #'as yet unclassified' }
NotesModeProjectParser >> populateProjectFileReferencesFromArray: array [
	"comment stating purpose of instance-side message"
	"scope: class-variables  &  instance-variables"	
			
	fileRefsForProject := array.
]
