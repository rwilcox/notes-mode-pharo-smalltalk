"
A NotesModeFileParserTest is a test class for testing the behavior of NotesModeFileParser
"
Class {
	#name : #NotesModeFileParserTest,
	#superclass : #TestCase,
	#category : #'NotesMode-Tests'
}

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testAddLineToDateIfRequiredPreviousLineCurrentLineCurrentDate [
	| nm scanLines res dict groups currentDate |

	dict := OrderedCollection new.
	groups := Dictionary new.
	nm := NotesModeFileParser new.

	"test that we get a new date created in the dictionary if we have a current date but no matches in the dictionary"
	currentDate := '05-01-2019' asDate.
	res := nm
		addLineToDateIfRequired: groups
		previousLine: '05-01-2019'
		currentLine: '=================='
		currentDate: currentDate.
	self should: [ (groups at: currentDate) isNil not ].

	"test that if we have a current date, check that this gets added to the containing lines array of the associated matches object"
	groups := Dictionary new.
	currentDate := '05-02-2019' asDate.
	groups at: currentDate put: MultilineKindMatch new.
	res := nm
		addLineToDateIfRequired: groups
		previousLine: '========================='
		currentLine: 'hello world'
		currentDate: currentDate.
	self should: [ (groups at: currentDate) _containingLinesArray size = 1 ].

	"test that when we have a line that sets the date to something new that new elements get added to THAT date's match kind object"
	currentDate := '05-02-2019' asDate.
	res := nm
		addLineToDateIfRequired: groups
		previousLine: '05-03-2019'
		currentLine: '========================'
		currentDate: currentDate.
	self should: [ groups size = 2 ].
	self should: [ (groups at: currentDate) _containingLinesArray size = 1 ].
	self should: [ (groups at: '05-03-2019' asDate) isNil not ]	"exception thrown if not found"
]

{ #category : #tests }
NotesModeFileParserTest >> testEntitiesForStreamItems [
	"comment stating purpose of instance-side message"
	"scope: class-variables  &  instance-variables"	
			
		| nm scanLines res |
	nm := NotesModeFileParser new.
	scanLines := {'Hello world' . ' - [TODO]: Make supper' . 'today this was the thing I did' . '- (V) [TODO]: another thing I did!'}.
	res := nm entitiesForStreamItems: scanLines.
	self should: [ res size = 2 ].
	self should: [ (res at: 1) kind = 'TODO' ]
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testIsCompletedItemLineFindsCompletedItems [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isCompletedItemLine: '-  (V) [TODO]: this thing' forKind: 'TODO'.
	self should: [ res = 1 ]
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testIsCompletedItemLineFindsIncompleteItems [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isCompletedItemLine: '- [TODO]: this thing' forKind: 'TODO'.
	self should: [ res = 0 ]
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testIsCompletedItemLineFindsIncompleteItemsLinesNotAnItem [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isCompletedItemLine: '# Hello world' forKind: 'TODO'.
	self should: [ res = -1 ]
]

{ #category : #'tests-as yet unclassified' }
NotesModeFileParserTest >> testIsDayEntryLinePreviousLine [
	| fp res |

	fp := NotesModeFileParser new.
	res := fp dateForDayEntryLine: '05-31-2019' previousLine: 'foobar'.
	self should: [ res = nil  ].
	
	res := fp dateForDayEntryLine: '================' previousLine: '05-31-2019'.
	self should: [ res = ('05-31-2019' asDate)  ].
	
	res := fp dateForDayEntryLine: '# 05-21-2019' previousLine: ''.
	self should: [ res = ('05-21-2019' asDate) ].

]

{ #category : #'as yet unclassified' }
NotesModeFileParserTest >> testIsLineOfKindKindMatchesExclusionMatche [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isLine: '- [TODO]: hello world' ofKind: 'TODO' excludeCompleted: false.
	self should: res
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testIsWikiWordLineFindsWikiWord [
	"comment stating purpose of message"

	| nm res |
	nm := NotesModeFileParser new.
	res := nm isWikiWordLine: '# <<RyanWilcox>>'.
	self should: res.
]

{ #category : #'as yet unclassified' }
NotesModeFileParserTest >> testLineOfKindMatchesExclusionNoMatch [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isLine: '- (V) [TODO]: hello world' ofKind: 'TODO' excludeCompleted: true.
	self should: (res = false)
]

{ #category : #'as yet unclassified' }
NotesModeFileParserTest >> testLineOfKindMatchesNoExclusionMatch [
		| nm res |
	nm := NotesModeFileParser new.
	res := nm isLine: '- (V) [TODO]: hello world' ofKind: 'TODO' excludeCompleted: false.
	self should: res.
]

{ #category : #'as yet unclassified' }
NotesModeFileParserTest >> testLineOfKindMatchesNoExclusionNoMatch [
	| nm res |
	nm := NotesModeFileParser new.
	res := nm isLine: '- (V) [TODO]: hello world' ofKind: 'NOTE' excludeCompleted: false.
	self should: res = false.
]

{ #category : #'tests-as yet unclassified' }
NotesModeFileParserTest >> testMatchesForImplicitDayEntryFromStreamItems [
	| nm scanLines res |

	nm := NotesModeFileParser new.
	scanLines := {'05-31-2019' . '==========================' . 'cause I am a back door man' . '' . '#06-01-2019' . 'I eat more chicken any man ever seen'}.
	
res := nm matchesForImplicitDayEntryFromStreamItems: scanLines.
self should: [ res size = 2 ].
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testMatchesForLinesMatchingKindExcludeCompleted [
	| nm scanLines res |
	nm := NotesModeFileParser new.
	scanLines := {'Hello world' . ' - [TODO]: Make supper' . 'today this was the thing I did' . '- (V) [TODO]: another thing I did!'}.
	res := nm matchesForLines: scanLines matchingKind: 'TODO' excludeCompleted: false.
	self should: [ res size = 2 ].
	self should: [ (res at: 1) kind = 'TODO' ]
]

{ #category : #'tests-accessing' }
NotesModeFileParserTest >> testMatchesForLinesMatchingKindExcludeCompletedFindsAllItimesWorksWhenNotFound [
	| nm scanLines res |
	nm := NotesModeFileParser new.
	scanLines := {'Hello world' . '- [TODO]: Make supper' . 'today this was the thing I did'}.
	res := nm matchesForLines: scanLines matchingKind: 'NOTE' excludeCompleted: false.
	self should: [ res size = 0 ] "because there are no NOTE items here"
]

{ #category : #'as yet unclassified' }
NotesModeFileParserTest >> testMatchesForLinesMatchingKindExcludeCompletedOnlyCompleted [
	| nm scanLines res txt|
	nm := NotesModeFileParser new.
	scanLines := {'Hello world' . '- [TODO]: Make supper' . 'today this was the thing I did' . '- (V) [TODO]: another thing I did!'}.
	res := nm matchesForLines: scanLines matchingKind: 'TODO' excludeCompleted: true.
	self should: [ res size = 1 ].
	self should: [ (res at: 1) kind = 'TODO' ].
	txt := (res at: 1) lineText.
	self should: [ txt = '- [TODO]: Make supper' ]
]

{ #category : #tests }
NotesModeFileParserTest >> testMultilineEntriesFindsWhenPeerOfTheItemIsFound [
	"If the Markdown indent level of the explicit item matches a newly found level, end the explicit item's MultilineKindMatch"

	| nm txt regexPattern|
	
	
	nm := NotesModeFileParser new.
	txt := '### - [NOTE]: this is a note with an extra line in here.
	
	Extra line
	
	### - [MEETING]: this is an unrelated item
	
	A line here
	'
]
