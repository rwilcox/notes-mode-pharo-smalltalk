Class {
	#name : #NotesFocusUI,
	#superclass : #ComposableModel,
	#instVars : [
		'text',
		'parentNotesUI'
	],
	#category : #NotesMode
}

{ #category : #specs }
NotesFocusUI class >> defaultSpec [
	"comment stating purpose of message"

<spec: #default>
	| bodyLayoutSpec |
	bodyLayoutSpec := SpecLayout composed.
	bodyLayoutSpec
		newRow: [ :c | 
			c
				add: #text. ].
			
		^ bodyLayoutSpec .
]

{ #category : #initialization }
NotesFocusUI >> initializeWidgets [
	"comment stating purpose of message"

	text := TextModel new. 
	text whenBuiltDo: [  :w | w widget font: (LogicalFont familyName: 'Source Sans Pro' pointSize: 16) ].
	self focusOrder add: text.
	
self whenWindowChanged: [ 
	self window whenClosedDo: [ self sentFocusContentsToParent  ]
].
]

{ #category : #accessing }
NotesFocusUI >> parentNotesUI [
	^ parentNotesUI
]

{ #category : #accessing }
NotesFocusUI >> parentNotesUI: anObject [
	parentNotesUI := anObject
]

{ #category : #'as yet unclassified' }
NotesFocusUI >> sentFocusContentsToParent [
	"comment stating purpose of message"

self text accept.

self parentNotesUI ifNotNil: [ 
	self parentNotesUI appendText: (self text getText string). 
	"cast it to a string, not text, to remove formatting. RPW 07/27/2019"
	].
]

{ #category : #accessing }
NotesFocusUI >> text [
	^ text
]

{ #category : #accessing }
NotesFocusUI >> text: anObject [
	text := anObject
]
