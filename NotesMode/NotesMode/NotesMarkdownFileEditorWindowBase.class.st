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
	#superclass : #ComposableModel,
	#instVars : [
		'openFileFileReference',
		'text',
		'defaultFileName',
		'defaultFolderPath'
	],
	#category : #NotesMode
}

{ #category : #adding }
NotesMarkdownFileEditorWindowBase >> addStandardToolbarItemsTo: group [
	group
				addItem: [ :item | 
					item
						name: 'Line#s';
						description: 'Line#s';
						icon: Smalltalk ui icons repairIcon;
						action: [ self turnOnLineNumbers ] ].
			group
				addItem: [ :item | 
					item
						name: 'Find';
						description: 'Find';
						icon: Smalltalk ui icons smallQAIcon;
						action: [ self openFindDialog ] ].
			group
				addItem: [ :item | 
					item
						name: 'Open...';
						description: 'Open';
						icon: Smalltalk ui icons openIcon;
						action: [ self openFileFromDialog. ] ].
			group
				addItem: [ :item | 
					item
						name: 'Save';
						description: 'Save';
						action: [ self saveFile ] ].
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

{ #category : #initialization }
NotesMarkdownFileEditorWindowBase >> initializeWidgets [
	"comment stating purpose of message"

	text := TextModel new.
	self focusOrder add: text.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> jumpToLine [
	|whatNumber startIndex stopIndex correspondingRes|
	
	whatNumber := TextEntryDialogWindow new openModal entryText asNumber .

	correspondingRes := text getText indexCorrespendingToLineNumber: whatNumber.
	startIndex := correspondingRes at: 1.
	stopIndex := correspondingRes at: 2.

	self text textArea selectFrom: startIndex  to: stopIndex.
	self text textArea scrollPane scrollSelectionIntoView.
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openFileFromDialog [
	| str uim stream |

	uim := UIManager default.

	(uim respondsTo: #chooseExistingFileReference:extensions:path:preview)
		ifTrue: [ openFileFileReference := uim
				chooseExistingFileReference: defaultFileName
				extensions: nil
				path: defaultFolderPath
				preview: nil ]
		ifFalse: [ openFileFileReference := (uim chooseFullFileNameMatching: #('*.md' '*.markdown') label: nil) asFileReference ].

	stream := openFileFileReference readStream.
	str := stream contents.
	stream close.
	text text: str.

	
]

{ #category : #accessing }
NotesMarkdownFileEditorWindowBase >> openFileReadStream [
	"Will always return a readStream, set to 0, of the current file"

	^ openFileFileReference readStream
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> openFindDialog [
	(text textArea) textArea announce: RubFindReplaceWindowRequired .
"^^^ yes really, textArea is like the scollableTextMorph, we want the actual textmoph inside that..."
]

{ #category : #'as yet unclassified' }
NotesMarkdownFileEditorWindowBase >> saveFile [
	| stream |

	stream := openFileFileReference writeStream.
	stream << text text string.
	stream close.
]

{ #category : #scrolling }
NotesMarkdownFileEditorWindowBase >> scrollDown: clicksWorth [
	self text textArea scrollPane vScrollbar scrollDown: clicksWorth .  "= clicking mouse  button X times"
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
NotesMarkdownFileEditorWindowBase >> turnOnLineNumbers [

(text textArea) withLineNumbers .

]
