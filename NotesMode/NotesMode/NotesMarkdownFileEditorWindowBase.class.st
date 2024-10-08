"
Class: provides a very basic functionality around being a window with a large text field that can open and save from a file


For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	defaultFileName:		<Object>
	defaultFolderPath:		<Object>
	openFileFileReference:		<Object>
	text:		<Object>


    Implementation Points
"
Class {
	#name : #NotesMarkdownFileEditorWindowBase,
	#superclass : #SpPresenter,
	#instVars : [
		'openFileFileReference',
		'text',
		'defaultFileName',
		'defaultFolderPath',
		'lineNumbersVisible',
		'projectFolderReferences',
		'dirty'
	],
	#classVars : [
		'notesWindowList'
	],
	#category : #NotesMode
}

{ #category : #adding }
NotesMarkdownFileEditorWindowBase class >> addToNotesWindowList: item [
	"comment stating purpose of class-side method"
	"scope: class-variables  &  class-instance-variables"

	"TODO: obviously a bug here when you go to close one of these things, 
	I'll implement that if / when I have to. WD-rpw 09-21-2024"
	
	notesWindowList ifNil: [  notesWindowList := OrderedCollection new ].
	
	notesWindowList add: item.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase class >> notesWindowList [
	"An OrderedCollection that contains every NotesMode window open. Useful to query or set attributes of the current window"

	^ notesWindowList .
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> acceptTextEdits [
	"comment stating purpose of message"

   "text editor accept."
	"text accept." "TODO: do I need to do this?"
]

{ #category : #adding }
NotesMarkdownFileEditorWindowBase >> addStandardToolbarItemsTo: group [
	group
				addItem: [ :item | 
					item
						name: 'Line#s';
						description: 'Line#s';
						icon: Smalltalk ui icons repairIcon;
						action: [ 
							lineNumbersVisible ifTrue: [self turnOffLineNumbers] ifFalse: [ 
							self turnOnLineNumbers ] ].
					].
			group
				addItem: [ :item | 
					item
						name: 'Find';
						description: 'Find';
						icon: Smalltalk ui icons smallQAIcon;
						action: [ self openFindDialog ] ].
			group
				addItem: [ :item || openSubMenu openMenu|
					openMenu := self newMenu .
					openSubMenu := openMenu  addGroup: [ :subMenuGroup |
						subMenuGroup addItem: [ : newSubItem |
							newSubItem name: 'Open file...';
							action: [self openFileFromDialog].
							 ].
						subMenuGroup addItem: [ :newSubItem |
							newSubItem name: 'Open Folder...';
							action: [self openFolderFromDialog].
							 ].
						].
					
					item
						name: 'Open...';
						description: 'Open';
						subMenu: openSubMenu.
			].
			group
				addItem: [ :item | 
					item
						name: 'Save';
						description: 'Save';
						action: [ self acceptTextEdits . self saveFile ] ].
			group
				addItem: [ :item | 
					item
						name: 'Jump';
						description: 'Jump To Line';
						action: [ self jumpToLine ] ].			
							

]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> defaultFileName [
	^ defaultFileName
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> defaultFileName: anObject [
	defaultFileName := anObject
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> defaultFolderPath [
	^ defaultFolderPath
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> defaultFolderPath: anObject [
	defaultFolderPath := anObject
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> fileParser [
	|output|
	
   output := NotesModeFileParser new.
   output currentFileReference: openFileFileReference.

  ^ output.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> fileRefsForAllInProject [
  |fileRefsForProject|
  fileRefsForProject := Array new.

	projectFolderReferences ifNotNil: [ fileRefsForProject := projectFolderReferences. ].
			
	^ { openFileFileReference } , fileRefsForProject.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> hasUnsavedContent [
	"comment stating purpose of message"

 ^ dirty. 
]

{ #category : #initialization }
NotesMarkdownFileEditorWindowBase >> initializeWidgets [
	"comment stating purpose of message"

	text := self newText .
	text withAdapterDo: [ :anAdaptor |
		anAdaptor grow: false
		 ].
	"do not want this growing, plus causes performance degradation with multi thousand line files
	RubScrolledTextMorph turns this on, we don't want that actually, thank you
	See also: https://github.com/pharo-project/pharo/pull/11583
	WD-rpw 09/03/2024"
	
	dirty := false.
	
	text whenTextChangedDo: [ 
		dirty ifFalse: [ 
		    self owner title: (self owner title, ' (*)').
		    dirty := true.
			 ]
		 ].
	
	
   "text askBeforeDiscardingEdits: true."
	"self askOkToClose: false."
	"self focusOrder add: text."
	lineNumbersVisible := false.
	
   NotesMarkdownFileEditorWindowBase addToNotesWindowList: self.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> jumpToLine [
	| whatNumber |
	
	whatNumber := TextEntryDialogWindow new openModal entryText asNumber.
	self jumpToLineNumber: whatNumber
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> jumpToLineNumber: whatNumber [
	| startIndex correspondingRes stopIndex txtModel scrollPane txtStr|
	
	txtModel := text adapter model.
	scrollPane := txtModel adapter widget scrollPane .
	
	txtStr  := txtModel text.
   correspondingRes := txtStr  indexCorrespendingToLineNumber: whatNumber.
	startIndex := correspondingRes at: 1.
	stopIndex := correspondingRes at: 2.
	self text selectionInterval: (startIndex to: stopIndex ). "textArea selectFrom: startIndex to: stopIndex."
	scrollPane scrollSelectionIntoView.
	"GrowlMorph openWithLabel: 'NotesMode' contents: 'could not goto line number (method not defined right now)'"
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openAndDisplayFromFileReference: ref [
	| stream str |
	openFileFileReference := ref.
	stream := openFileFileReference readStream.
	str := stream contents.
	stream close.
	text text: str.
	"text hasUnacceptedEdits: false"
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openFileFromDialog [
	| uim |
	uim := UIManager default.
	(uim
		respondsTo: #'chooseExistingFileReference:extensions:path:preview')
		ifTrue: [ openFileFileReference := uim
				chooseExistingFileReference: defaultFileName
				extensions: nil
				path: defaultFolderPath
				preview: nil ]
		ifFalse: [ openFileFileReference := (uim
				chooseFullFileNameMatching: #('*.md' '*.markdown')
				label: nil) asFileReference ].
	self openAndDisplayFromFileReference: openFileFileReference.
	self owner title: (openFileFileReference basename).
	dirty := false.
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> openFileReadStream [
	"Will always return a readStream, set to 0, of the current file"

	^ openFileFileReference readStream
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openFindDialog [
   text doTextFind .
	"(text textArea) textArea announce: RubFindReplaceWindowRequired ."
"^^^ yes really, textArea is like the scollableTextMorph, we want the actual textmoph inside that..."
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openFolderFromDialog [
	"comment stating purpose of instance-side message"

	"scope: class-variables  &  instance-variables"

	| uim dir noteFileReferences |
	uim := UIManager default.
	dir := uim chooseDirectory.
	dir entries ifNil: [ ^ 0 ].
	noteFileReferences := dir entries
		select: [ :currDirectoryEntry |  "its always a DiskDirectoryEntry"
			| output|
			output := (currDirectoryEntry isDirectory) not.
			output
				ifTrue: [ output := ( (currDirectoryEntry fullName endsWith: '.md') or: [ currDirectoryEntry fullName endsWith: '.markdown' ]) ].
			output ]
		thenCollect: [ :currDirectoryEntry |
			currDirectoryEntry asFileReference.
		] .
	
	projectFolderReferences := noteFileReferences.

]

{ #category : #'Model Related' }
NotesMarkdownFileEditorWindowBase >> readStreamsForAllInProject [

  ^ self fileRefsForAllInProject collect: [ :currentFileReference |
     currentFileReference readStream.	
	].

]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> saveFile [
	| stream |

   openFileFileReference ifNil: [ |fref|
	    fref := self saveFileFromDialog .
	    openFileFileReference := fref asFileReference.
	].
 
   stream := ZnNewLineWriterStream on: (openFileFileReference writeStream).
	stream << text text string.
	stream close.
	
   dirty := false.
  self owner title: (openFileFileReference basename).
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> saveFileFromDialog [
	"the create new file version of openFileFromDialog"	
			
	| uim |
	
	uim := UIManager default.
	
	^ uim chooseForSaveFileReference: 'Save file' extensions: #('md') path: (FileLocator home fullPath).
	
]

{ #category : #scrolling }
NotesMarkdownFileEditorWindowBase >> scrollDown: clicksWorth [
	self text textArea scrollPane vScrollbar scrollDown: clicksWorth .  "= clicking mouse  button X times"
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> sendToTextFilter [
	"take the current selection and send it as an attribute of a new Playground"

	| textToFilter playground bindings t|

	textToFilter := text adapter editor selection.

	bindings := Dictionary newFrom: {
	  (#inText -> textToFilter). 
	  (#inNotesWindow -> self). 
	  (#allText -> text).
	  (#entities) -> [|fp| fp:= self fileParser. fp entitiesForStreamItems: (fp currentFileReferenceAsStream). ] }.
	
	"playground := Smalltalk tools workspace.
	playground openContents: 'inText'."
	playground := StPlayground new.
	playground contents: 'inText' .
	
	"will be a StPlayground"
	t := playground page text.  "text is a SpPlaygroundInteractionModel ??"
	"playground setBindings: bindings."
	
	playground openWithSpec .
	
"TODO: fix me!!"
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> text [
	^ text
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> text: anObject [
	text := anObject
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> turnOffLineNumbers [
	"comment stating purpose of message"

self text adapter widget withoutLineNumbers .

lineNumbersVisible := false.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> turnOnLineNumbers [

self text adapter widget withLineNumbers .

lineNumbersVisible := true.

]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> windowIsClosing [
	"called from SpecWindow (SystemWindow) delete.

There is NO take-backies at this point. We're too far gone and the window WILL be closing with or without us.
 There is no cancel, only save (or not)"

	self hasUnsavedContent
		ifTrue: [ | res |

			res := UIManager default questionWithoutCancel: 'Save edits?'.
			"Thankfully we CAN use UIManager to show a modal dialog box, which is a blocking operation"

			res
				ifTrue: [ self acceptTextEdits.
					self saveFile ].

			Transcript
				show: 'last chance rescue text BEGIN vvvvvvvvvvvvvvvv';
				cr;
				show: self text text string;
				cr;
				show: '^^^^^^^^^^^^^^^ last chance rescue END' ].

	Transcript
		show: 'NoteMode window closing.';
		cr
]
