Class {
	#name : #NotesUI,
	#superclass : #NotesMarkdownFileEditorWindowBase,
	#instVars : [
		'menu',
		'wikiWordsList',
		'calendarNavigator',
		'entryPeekText',
		'dateWorkEntriesCache'
	],
	#category : #NotesMode
}

{ #category : #specs }
NotesUI class >> defaultSpec [
	<spec: #default>
	| bodyLayoutSpec rightSidebarLayoutSpec calendarPickerLayoutSpec |

	bodyLayoutSpec := SpecLayout composed.
	rightSidebarLayoutSpec := SpecLayout composed.
	calendarPickerLayoutSpec := SpecLayout composed.

calendarPickerLayoutSpec newRow: [ :c |
	c add: #calendarNavigator;
	add: #entryPeekText
	 ].

	rightSidebarLayoutSpec
		newColumn: [ :c | 
			c
				add: #wikiWordsList;
				add: calendarPickerLayoutSpec  ].

	bodyLayoutSpec
		newRow: [ :c | 
			c
				add: #text;
				addVSplitter;
				"VSplitter lets the columns be resizable"
					add: rightSidebarLayoutSpec ].
	^ SpecLayout composed
		newColumn: [ :c | 
			c
				add: #menu height: self toolbarHeight;
				add: bodyLayoutSpec ];
		yourself
]

{ #category : #example }
NotesUI class >> example [
	^ self new openWithSpec.
]

{ #category : #'acessing text' }
NotesUI >> appendText: itText [
	"comment stating purpose of message"

self text accept.  "need to do this to refresh the model with the pending text. Thanks, Smalltalk. RPW 07/27/2019"
	self text text: ( (self text text), '
	
	', itText ).
	
]

{ #category : #accessing }
NotesUI >> calendarNavigator [
	^ calendarNavigator
]

{ #category : #accessing }
NotesUI >> calendarNavigator: anObject [
	calendarNavigator := anObject
]

{ #category : #'as yet unclassified' }
NotesUI >> displayMultipleLinesofType: aString [
	"a hack method until we make this better..."

	| stream p listItems tmp |

	listItems := OrderedCollection new.

	stream := LineByLineStream new.
	stream stream: self openFileReadStream.

	p := NotesModeFileParser new.
	tmp := p matchesForStreamItems: stream matchingKind: aString excludeCompleted: true.  "TODO: actuallyy write this function..."

	tmp do: [ :current | listItems add: current lineText , ' |||| ' , current lineNumber asString ].

	wikiWordsList items: listItems.
	wikiWordsList refreshListItems .
]

{ #category : #'as yet unclassified' }
NotesUI >> displaySingleLinesOfType: aString [ 
	| stream p listItems tmp |

	listItems := OrderedCollection new.

	stream := LineByLineStream new.
	stream stream: self openFileReadStream.

	p := NotesModeFileParser new.
	tmp := p matchesForStreamItems: stream matchingKind: aString excludeCompleted: true.

	tmp do: [ :current | listItems add: current lineText , ' |||| ' , current lineNumber asString ].

	wikiWordsList items: listItems.
	wikiWordsList refreshListItems .
]

{ #category : #'UI adaptors' }
NotesUI >> displayTodoItems [
	self displaySingleLinesOfType: 'TODO'.
]

{ #category : #'UI adaptors' }
NotesUI >> displayWikiWords [
	"read and display wiki words for this item in our list"

	| stream p listItems |

	listItems := OrderedCollection new.

	stream := LineByLineStream new.
	stream stream: (self openFileReadStream).

	p := NotesModeFileParser new.
	(p matchesForImplicitWikiWordsFromStreamItems: stream)
		do: [ :current | listItems add: current lineText , ' |||| ' , current lineNumber asString ].

	wikiWordsList items: listItems.
	wikiWordsList refreshListItems.
]

{ #category : #accessing }
NotesUI >> entryPeekText [
	^ entryPeekText
]

{ #category : #accessing }
NotesUI >> entryPeekText: anObject [
	entryPeekText := anObject
]

{ #category : #'Model Related' }
NotesUI >> getLogEntriesByDate [
	"comment stating purpose of message"

	| p lblstream |

	p := NotesModeFileParser new.
	lblstream := LineByLineStream new.
	lblstream stream: self openFileReadStream .
	^ p matchesForImplicitDayEntryFromStreamItems: lblstream.
]

{ #category : #'UI adaptors' }
NotesUI >> handleDateClicked: whatDate [
	(dateWorkEntriesCache includesKey: whatDate) 
	ifTrue: [ entryPeekText text: ( (dateWorkEntriesCache at: whatDate) textLines ) ] 
	ifFalse: [ entryPeekText text: 'no entry for this date found' ].
]

{ #category : #initialization }
NotesUI >> initializeWidgets [
	"comment stating purpose of message"

	| calendarAsMorph |

	menu := MenuModel new
		addGroup: [ :group | 
			super addStandardToolbarItemsTo: group.
			
			group
				addItem: [ :item | 
					item
						name: 'List Entities';
						description: 'List Entities';
						subMenu: self listSubMenu.
						];
				addItem: [ :item | 
					item
						name: 'Focus';
						description: 'New window whose contents will get appended to the bigger one';
						action: [ self spawnFocusWindow ] ] ;
					
				addItem: [ :item |
					item
					name: 'insert';
					description: 'Insert';
					subMenu: self insertSubMenu .
					].
				 ].
	menu applyTo: self.
	
	wikiWordsList := self newList.	" a ListModel"
	wikiWordsList items: {'entity list'}.
	"wikiWordsList whenSelectedItemChanged: [ :txtLine|| numberLocation |
		numberLocation := txtLine findString: '||||'.
		
		 Transcript show: (txtLine copyFrom: numberLocation + 4).  
		].
	"
	"TODO: implement me properly."
	
	entryPeekText := TextModel new.
	entryPeekText text: 'Scratch or focus text'.

	calendarAsMorph := NotesFocusMonthMorph openOn: Date today.
	calendarNavigator := calendarAsMorph asSpecAdapter.
	calendarAsMorph announcer
		subscribe: ChoseDate
		do: [ :inEvent | 
			| whatDate |

			whatDate := inEvent date.
			self handleDateClicked: whatDate
			"entryPeekText text: whatDate mmddyyyy " ].

	super initializeWidgets .
	
]

{ #category : #'UI adaptors' }
NotesUI >> insertStringAtCursor: string [
	"comment stating purpose of message"

	| selectedLocation newInput input currentCharacterLocation|

	self text accept.

	selectedLocation := self text getSelection.
	currentCharacterLocation := selectedLocation first.

	input := self text text.

	newInput := input copyReplaceFrom: currentCharacterLocation to: (currentCharacterLocation -1) with: string.
	"the -1 is oddball here, but it prevents out of bounds errors if we do this at the end of the text. WD-rpw 11-03-2019"

	self text text: newInput.
	self text textArea selectFrom: currentCharacterLocation to: currentCharacterLocation + string size.
	self text textArea scrollPane scrollSelectionIntoView.
	"textArea = RubScrolledTextMorph. ScrollPane = RubTextScrollPane. This was seriously the easist way to reset the scrolling state. WD 10-27-2019"
]

{ #category : #'UI Builder' }
NotesUI >> insertSubMenu [
"thanks very much to the ApplicationWithToolbar Spec-Example, in the image"

	^ MenuModel new addGroup: [ :group |
		group addItem: [ :item |
			item name: 'Work Log';
			action: [ self insertStringAtCursor: (SnippetsCollection new worklogSnippet ) ] ].
		
		group addItem: [ :item |
			item name: 'Meeting';
			action: [ self insertStringAtCursor: (SnippetsCollection new meetingSnippet) ]	].
		group addItem: [ :item |
			item name: 'TODO';
			action: [ self insertStringAtCursor: '- [TODO]: ' ] ].
		].
	  
]

{ #category : #'as yet unclassified' }
NotesUI >> listSubMenu [
	^ MenuModel new addGroup: [ :group |
		group addItem: [ :item |
			item name: 'TODOs';
			action: [ self displayTodoItems ].
			 ].
		group addItem: [ :item |
			item name: 'REVIEWs';
			action: [ self displaySingleLinesOfType: 'REVIEW' ]. ].
		
		group addItem: [ :item |
			item name: 'WikiWords';
			action: [ self displayWikiWords  ]. ].
		
		group addItem: [ :item |
			item name: 'Projects';
			action: [ self displayMultipleLinesofType: 'PROJECT'  ]. ].
		
		group addItem: [ :item |
			item name: 'Meetings';
			action: [ self displayMultipleLinesofType: 'MEETING'  ]. ]
		 ].
	 
]

{ #category : #accessing }
NotesUI >> menu [
	^ menu
]

{ #category : #accessing }
NotesUI >> menu: anObject [
	menu := anObject
]

{ #category : #'as yet unclassified' }
NotesUI >> openFileFromDialog [
	super openFileFromDialog .
	dateWorkEntriesCache := self getLogEntriesByDate.
]

{ #category : #'as yet unclassified' }
NotesUI >> spawnFocusWindow [
	|f|
	f := NotesFocusUI new.
	f parentNotesUI: self.
	f openWithSpec.
	
]

{ #category : #accessing }
NotesUI >> wikiWordsList [
	^ wikiWordsList
]

{ #category : #accessing }
NotesUI >> wikiWordsList: anObject [
	wikiWordsList := anObject
]
