Class {
	#name : #NotesUI,
	#superclass : #NotesMarkdownFileEditorWindowBase,
	#instVars : [
		'menu',
		'wikiWordsList',
		'calendarNavigator',
		'entryPeekText',
		'dateWorkEntriesCache',
		'currentlyListedKindMatches',
		'clearAllDeskAccessories'
	],
	#category : #NotesMode
}

{ #category : #layout }
NotesUI class >> defaultLayout [
	"comment stating purpose of class-side method"
	"scope: class-variables  &  class-instance-variables"

	^ self defaultSpec .
]

{ #category : #specs }
NotesUI class >> defaultSpec [
	<spec: #default>
	| bodyLayoutSpec rightSidebarLayoutSpec calendarPickerLayoutSpec res rLayout|

	bodyLayoutSpec := SpBoxLayout newHorizontal .
	rightSidebarLayoutSpec := SpBoxLayout newVertical .
	calendarPickerLayoutSpec := SpBoxLayout  newVertical .

calendarPickerLayoutSpec add: #calendarNavigator.
calendarPickerLayoutSpec add: #entryPeekText.

rightSidebarLayoutSpec add: #wikiWordsList.
rightSidebarLayoutSpec add: calendarPickerLayoutSpec .
"calendarPickerLayoutSpec newRow: [ :c |
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
				'VSplitter lets the columns be resizable'
					add: rightSidebarLayoutSpec ]."

	res := SpBoxLayout newHorizontal.
	res add: #text.
	"res newSplitter ."
	
	res add: rightSidebarLayoutSpec  .
	"res add: #menu."
	rLayout := SpBoxLayout newVertical.
	rLayout add: #menu expand: false.
	rLayout add: res.
	^ rLayout.
]

{ #category : #example }
NotesUI class >> example [
   |output|
   output := self new.

   "output layout: #defaultSpec.	"
	^ output open  .
]

{ #category : #specs }
NotesUI class >> layoutWithoutDeskAccessories [
  <spec:#withoutDAs>

	| bodyLayoutSpec |
	bodyLayoutSpec := SpBoxLayout newVertical .
	bodyLayoutSpec add: #menu expand: false.
	bodyLayoutSpec add: #text.
		
	^ bodyLayoutSpec .		
]

{ #category : #'Public API' }
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

{ #category : #'Public API' }
NotesUI >> currentlyListedKindMatches [
	^ currentlyListedKindMatches
]

{ #category : #accessing }
NotesUI >> currentlyListedKindMatches: anObject [
	currentlyListedKindMatches := anObject
]

{ #category : #'UI adaptors' }
NotesUI >> displayMultipleLinesofType: aString [
	"a hack method until we make this better..."

	| listItems tmp |
	"TODO: right function here?""wikiWordsList refreshListItems ."
	tmp := self getMultipleLinesOfType: aString.
	listItems := OrderedCollection new.
	self currentlyListedKindMatches: tmp.
	listItems := self setEntityListTo: tmp
]

{ #category : #'UI adaptors' }
NotesUI >> displaySingleLinesOfType: aString [
	| tmp |
	tmp := self kindMatchesForKindInModel: aString excludeCompleted: true.
	
	self setEntityListTo: tmp.
]

{ #category : #'UI adaptors' }
NotesUI >> displayTodoItems [
	self displaySingleLinesOfType: 'TODO'.
]

{ #category : #'UI adaptors' }
NotesUI >> displayWikiWords [
	"read and display wiki words for this item in our list"

	| listItems |
	"wikiWordsList refreshListItems."
	listItems := self getWikiWords.
	wikiWordsList items: listItems
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

	| p |
	p := NotesModeProjectParser new.
	p
		populateProjectFileReferencesFromArray: self fileRefsForAllInProject .
	^ p matchesForImplicitDayEntry
]

{ #category : #'UI adaptors' }
NotesUI >> getMultipleLinesOfType: aString [
   "the string is the kind of Notes entity"
	| stream tmp|

	stream := LineByLineStream new.
	stream stream: self openFileReadStream.

	tmp := self kindMatchesForKindInModel: aString excludeCompleted: true.
	"TODO: right function here?"

   ^ tmp.
]

{ #category : #'as yet unclassified' }
NotesUI >> getSingleLinesOfType: tmp [
	"comment stating purpose of instance-side method"
	"scope: class-variables  &  instance-variables"

	^ self kindMatchesForKindInModel:  tmp excludeCompleted: true.
]

{ #category : #'UI adaptors' }
NotesUI >> getWikiWords [

	| p listItems |
	p := NotesModeProjectParser new.
	p populateProjectFileReferencesFromArray:
		self fileRefsForAllInProject.
	listItems := OrderedCollection new.

	p matchesForImplicitWikiWords do: [ :current |
		listItems add:
			current lineText , ' |||| ' , current lineNumber asString
			, ' |||| ' , current foundInFileReference basename ].
	^ listItems
]

{ #category : #'UI adaptors' }
NotesUI >> handleDateClicked: whatDate [
	(dateWorkEntriesCache includesKey: whatDate) 
	ifTrue: [ entryPeekText text: ( (dateWorkEntriesCache at: whatDate) textLines ) ] 
	ifFalse: [ entryPeekText text: 'no entry for this date found' ].
]

{ #category : #initialization }
NotesUI >> handleEntityListClickOn: selectedInfo [
	| numberLocation txtLineSplits fileName otherFileNotesMode fileRefIndex fileRefToZoomInto a txtLine|
	txtLine := selectedInfo selectedItem.
	txtLine ifNotNil: [ 
		txtLineSplits := txtLine substrings: '||||'.
		txtLineSplits size > 1
			ifTrue: [ 
				
				numberLocation := (txtLineSplits at: 2) trim.
				fileName := (txtLineSplits at: 3) trim.
				
				(fileName = (openFileFileReference basename)) ifTrue: [  
					self jumpToLineNumber: numberLocation asInteger ]
				ifFalse: [ 
					
					fileRefIndex := projectFolderReferences findFirst: [ :current |
						(current basename) = fileName.
					].
				  fileRefToZoomInto := projectFolderReferences at: fileRefIndex.
				
					otherFileNotesMode := NotesUIFileEditor new.
					a := otherFileNotesMode openWithSpec.
					a title: fileName.
					
					otherFileNotesMode openAndDisplayFromFileReference: fileRefToZoomInto.
					otherFileNotesMode jumpToLineNumber: numberLocation asInteger.
					
					 ]
			].
	].
]

{ #category : #initialization }
NotesUI >> handleToggleDeskAccessories [
	"by default we have lots of desk accessories: a calendar, scratch text, entity view.
	Sometimes the user doesn't want all that. (Sometimes they do)"

	| newLayout |
	
	clearAllDeskAccessories
		ifNil: [ newLayout := self class layoutWithoutDeskAccessories.
			clearAllDeskAccessories := true ]
		ifNotNil: [ newLayout := self class defaultSpec. clearAllDeskAccessories := nil. ].
	self needRebuild: true.
	
	"if I don't do this then new edits to the text are not even accepted. RPW 10/28/2020"
	"text := TextModel new.
	text text: oldText."
	self replaceLayoutWith:  newLayout
]

{ #category : #initialization }
NotesUI >> initializeWidgets [
	"comment stating purpose of message"

	| calendarAsMorph |
	menu := self newMenuBar addGroup: [ :group |
		        super addStandardToolbarItemsTo: group.
		        self setOurToolbarItemsTo: group ].
	"menu applyTo: self."
	wikiWordsList := self newList. "a ListModel"
	wikiWordsList items: { 'entity list' }.
	wikiWordsList whenActivatedDo: [ :txtLine |
		self handleEntityListClickOn: txtLine ].

	"TODO: implement me properly."
	
	entryPeekText := self newText.
	entryPeekText text: 'Scratch or focus text'.

	calendarAsMorph := NotesFocusMonthMorph openOn: Date today.
	calendarNavigator := SpMorphPresenter new
		                     morph: calendarAsMorph;
		                     yourself.
	calendarAsMorph announcer
		when: ChoseDate
		do: [ :inEvent |
			| whatDate |
			whatDate := inEvent date.
			self handleDateClicked: whatDate
			"entryPeekText text: whatDate mmddyyyy " ]
		for: self.
	super initializeWidgets
]

{ #category : #'Public API' }
NotesUI >> insertStringAtCursor: string [
	"comment stating purpose of message"

	| selectedLocation newInput input currentCharacterLocation|

	"self text accept."

   self text insertAndSelectAfterCurrentSelection: string.
	

   false ifTrue: [ 
	selectedLocation := self text getSelection.
	currentCharacterLocation := selectedLocation first.

	input := self text text.
	newInput := input copyReplaceFrom: currentCharacterLocation to: (currentCharacterLocation -1) with: string.
	"the -1 is oddball here, but it prevents out of bounds errors if we do this at the end of the text. WD-rpw 11-03-2019"

	self text text: newInput.
	self text textArea selectFrom: currentCharacterLocation to: currentCharacterLocation + string size.
	self text textArea scrollPane scrollSelectionIntoView.
	"textArea = RubScrolledTextMorph. ScrollPane = RubTextScrollPane. This was seriously the easist way to reset the scrolling state. WD 10-27-2019"
	
  ].
]

{ #category : #'UI Builder' }
NotesUI >> insertSubMenu [
"thanks very much to the ApplicationWithToolbar Spec-Example, in the image"
   |aMenu|
   aMenu := self newMenu.
   aMenu addGroup: [ :group |
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
	  
	^ aMenu.
]

{ #category : #'Public API' }
NotesUI >> kindMatchesForKindInModel: aString excludeCompleted: exclude [
	| p |
	
	p := NotesModeProjectParser new.
	p populateProjectFileReferencesFromArray: self fileRefsForAllInProject  .
	^ p
		matchesForMatchingKind: aString
		excludeCompleted: exclude
]

{ #category : #'UI Builder' }
NotesUI >> listSubMenu [
	^ SpMenuPresenter new addGroup: [ :group |
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

{ #category : #'UI adaptors' }
NotesUI >> setEntityListTo: tmp [
   "takes a Collection of KindMatches, formats them per standard and adds them to the entity list"

	| listItems |
	listItems := tmp collect: [ :current |
		             current lineText , ' |||| '
		             , current lineNumber asString , ' |||| '
		             , current foundInFileReference basename ].

	wikiWordsList items: listItems.
	^ listItems
]

{ #category : #initialization }
NotesUI >> setOurToolbarItemsTo: group [
group
				addItem: [ :item | 
					item
						name: 'List Entities';
						description: 'List Entities';
						subMenu: self listSubMenu ];
				addItem: [ :item | 
					item
						name: 'Focus';
						description: 'New window whose contents will get appended to the bigger one';
						action: [ self spawnFocusWindow ] ];
				addItem: [ :item | 
					item
						name: 'insert';
						description: 'Insert';
						subMenu: self insertSubMenu ] ;
				addItem: [ :item |
						item name: 'Toggle DAs';
						description: 'Toggle Desk Accessories';
						action: [ self handleToggleDeskAccessories ]
						 ].
]

{ #category : #'as yet unclassified' }
NotesUI >> spawnFocusWindow [
	|f|
	f := NotesFocusUI new.
	f parentNotesUI: self.
	f open.
	
]

{ #category : #accessing }
NotesUI >> wikiWordsList [
	^ wikiWordsList
]

{ #category : #accessing }
NotesUI >> wikiWordsList: anObject [
	wikiWordsList := anObject
]
