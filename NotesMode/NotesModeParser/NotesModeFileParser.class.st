Class {
	#name : #NotesModeFileParser,
	#superclass : #Object,
	#instVars : [
		'inputLines',
		'currentFileReference'
	],
	#category : #NotesModeParser
}

{ #category : #'multi line items' }
NotesModeFileParser >> addLineToDateIfRequired: groups previousLine: lastLine currentLine: each currentDate: current [
	"returns the current date object that this line is classified under. Might be the currentDate value, might be another one if the text indicates that the date has shifted"

	| lineDate |

	lineDate := self dateForDayEntryLine: each previousLine: lastLine.

	"no date for today. We have a current date. This must go under the current date"
	(lineDate isNil and: current isNil = false)
		ifTrue: [ | currentMatch |

			currentMatch := groups at: current.
			currentMatch appendLine: each.
			^ current ].

	"no date for this line AND there was nothing in the past. Ignore it."
	".............."

	"we have a date for this line! but we have a new line now, because it isn't what it once was!"
	(lineDate isNil = false and: (lineDate = current) not)
		ifTrue: [ 
			| match |
			match := MultilineKindMatch new.
			match foundInFileReference: (self currentFileReference ).
			
			groups at: lineDate put: match.
			^ lineDate ].

	"if we have a date for this line. And there was nothing there in the past, set this it the current"
	(lineDate isNil = false and: (groups includesKey: lineDate) = false)
		ifTrue: [ 
			|match|
			match := MultilineKindMatch new.
			match foundInFileReference: (self currentFileReference ).
			groups at: lineDate put: match.
			^ lineDate ].

	^ current
]

{ #category : #accessing }
NotesModeFileParser >> currentFileReference [
	^ currentFileReference
]

{ #category : #accessing }
NotesModeFileParser >> currentFileReference: anObject [
	currentFileReference := anObject
]

{ #category : #'as yet unclassified' }
NotesModeFileParser >> currentFileReferenceAsStream [
	"comment stating purpose of instance-side message"
	"scope: class-variables  &  instance-variables"	
			
	| output |
	
  output := LineByLineStream new.
  output stream: self currentFileReference readStream.

  ^ output.
]

{ #category : #'multi line items' }
NotesModeFileParser >> dateForDayEntryLine: line previousLine: prevLine [
	"Do someday support hash tag header lines, for now whatever.
	
	we have some conditions here:
	
	  1. previousLine is null, and line looks like maybe a day (setex format)... but we're not sure yet
	  2. previousLine is null, and line IS a day (hash format)
	  3. previousLine is a date AND line is a ================== (aka: they used setext)
	  4. previousLine is something but line is a date with hash format
	  5. Line is not a date (hash format).
	
	Returns a Date object (the date the day entry is in question for OR nil)
	"

	| regexMatchLineDayLine regexMatchesSeperatorLine prevMatched regexMatchLineDayLineSetex |

	regexMatchLineDayLine := '\d\d?[-/]\d\d?[-/]\d\d\d\d'.
	regexMatchLineDayLineSetex := '#\W*\d\d?[-/]\d\d?[-/]\d\d\d\d'.

	(line matchesRegex: regexMatchLineDayLineSetex)
		ifTrue: [ ^ line asDate ].

	regexMatchesSeperatorLine := '=+'.
	prevLine ifNil: [ prevMatched := false ] ifNotNil: [ prevMatched := prevLine matchesRegex: regexMatchLineDayLine ].	
		"^^^^^^ if we had a previous line, did it match the regex.
Need this test because we could just run into a date as its own line. If we are still here we don't know if there's a header line, so we check.	
	"


	((line matchesRegex: regexMatchesSeperatorLine) and: prevMatched)
		ifTrue: [ ^ prevLine asDate ]
		ifFalse: [ ^ nil ]
]

{ #category : #'multi line items' }
NotesModeFileParser >> days [
	"comment stating purpose of message"

	
]

{ #category : #'as yet unclassified' }
NotesModeFileParser >> entitiesForStreamItems: stream [
	"comment stating purpose of instance-side message"
	"scope: class-variables  &  instance-variables"	
			
	| output counter |
	output := OrderedCollection new.
	counter := 1.
	
   stream do: [ :each || res|
     	res := self getKindMatchForLine: each lineNumberInFile: counter.
	     res ifNotNil: [ output add: res. ]. 
	     counter := counter + 1.
	 ].

  ^ output.
]

{ #category : #testing }
NotesModeFileParser >> getKindMatchForLine: line lineNumberInFile: lineNumber [
	"If a line has any kind of explicit entity declaration, return a KindMatch for it as appropritae. (else null)"
	
	|res output whatEntityKind |
  res := self isCompletedItemLine: line forKind: '.+'.
  
  (res > -1) ifTrue: [ | whatKindRegex regexRes|
	  whatKindRegex := '^.*\[(.+)\]\:.+'.
	  regexRes := RxMatcher forString: whatKindRegex.
	  (regexRes matches: line) ifTrue: [ 
		  whatEntityKind := (regexRes subexpression: 2)
		].
	].

  (res = -1) ifTrue: [ 
	 "it was not an explicit entity. Check for implicit entries like Wiki words"
	(self isWikiWordLine: line) ifTrue: [ whatEntityKind := 'wikiword' ].
  ].

  whatEntityKind ifNotNil: [  
	  output := KindMatch new.
	  output completed: (res = 1);
	  kind: whatEntityKind;
	  lineNumber: lineNumber;
	  lineText: line;
	  foundInFileReference: currentFileReference;
	  tagsArrayFromString: (Utils tagStringFromLine: line).
  ].
  ^ output.
]

{ #category : #accessors }
NotesModeFileParser >> inputLines [
	^ inputLines
]

{ #category : #accessors }
NotesModeFileParser >> inputLines: anObject [
	inputLines := anObject
]

{ #category : #'single line sections' }
NotesModeFileParser >> isCompletedItemLine: line forKind: kind [
	"takes an Item line aka - [TODO]: or - (v) [TODO]: and returns if it complete or not.
	
	returns 0 (incomplete) , 1 (completed), -1 (not a one at all)
	"

	| regexPatternUndone regexPatternDone |
	regexPatternUndone := '^.*[*-]' , ' \[' , kind , '\]\:.+'.
	regexPatternDone := '^.*[*-]' , ' .+ \[' , kind , '\]\:.+'.
	(line matchesRegex: regexPatternUndone)
		ifTrue: [ ^ 0 ].
	(line matchesRegex: regexPatternDone)
		ifTrue: [ ^ 1 ].
	^ -1
]

{ #category : #'single line sections' }
NotesModeFileParser >> isLine: line ofKind: kind excludeCompleted: newOnly [
	| lineInfo |
	lineInfo := self isCompletedItemLine: line forKind: kind.
	
	(lineInfo = 1) ifTrue: [ ^ ( newOnly not) ].
	^ (lineInfo > -1).
]

{ #category : #'single line sections' }
NotesModeFileParser >> isWikiWordLine: line [
	"comment stating purpose of message"

	| regexPatternWikiWord |
	regexPatternWikiWord := '^.*<<([A-Za-z_0-9\-]+)>>.*'.
	^ line matchesRegex: regexPatternWikiWord
]

{ #category : #'multi line items' }
NotesModeFileParser >> matchesForImplicitDayEntryFromStreamItems: stream [
	"returns a dictionary where every key is a Smalltalk Date object and every value a MultilineKindMatch of the text entries made during that date object (aka: until the next one)"

	| groups current lastLine |

	groups := Dictionary new.
	lastLine := nil.
	current := nil.
	stream
		do: [ :each | 
			current := self
				addLineToDateIfRequired: groups
				previousLine: lastLine
				currentLine: each
				currentDate: current.
			lastLine := each ].

	^ groups
]

{ #category : #'single line sections' }
NotesModeFileParser >> matchesForImplicitWikiWordsFromStreamItems: stream [
	"comment stating purpose of message"

	| output counter |
	output := OrderedCollection new.
	counter := 1.
	stream
		do: [ :each | 
			(self isWikiWordLine: each)
				ifTrue: [ | kindMatch |
					kindMatch := KindMatch new.
					kindMatch
						completed: false;
						kind: 'wikiword';
						lineText: each;
						lineNumber: counter.
						output add: kindMatch . ].
			counter := counter + 1 ].
	^ output
]

{ #category : #'single line sections' }
NotesModeFileParser >> matchesForLines: inCollection matchingKind: kind excludeCompleted: onlyNew [
	^ self
		matchesForStreamItems: (ReadStream on: inCollection)
		matchingKind: kind
		excludeCompleted: onlyNew
]

{ #category : #'single line sections' }
NotesModeFileParser >> matchesForStreamItems: stream matchingKind: kind excludeCompleted: excludeCompleted [
	| entities|
	
	entities := self entitiesForStreamItems: stream.
	^ entities select: [ :currEntity || includeValue|
		  includeValue := false.
		
		  (currEntity kind = kind) ifTrue: [ 
			  includeValue := true.
			  excludeCompleted ifTrue: [ 
				  (currEntity completed) ifTrue: [ includeValue := false ].   
			  ].
			].
		   includeValue.
		 ].
]

{ #category : #'single line sections' }
NotesModeFileParser >> matchesKind: kind excludingCompleted: excludingCompleted [
	"comment stating purpose of message"

^ self matchesForLines: (self inputLines) matchingKind: kind excludeCompleted: excludingCompleted .
]

{ #category : #'as yet unclassified' }
NotesModeFileParser >> whatOutlineLevelFor: line [
	"return the number of markdown indents this line has

	TODO: make it work for sextext, etc
	"

	| regexPattern  didMatch output |
	
	output := 0.
	regexPattern := '^(#*)\W?-.*\[\w+\]\:.+'.
	didMatch := regexPattern matches: line.
	didMatch
		ifTrue: [ output := (regexPattern subexpression: 2) size ].
	^ output
]
