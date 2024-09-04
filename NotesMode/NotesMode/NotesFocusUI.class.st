Class {
	#name : 'NotesFocusUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'text',
		'parentNotesUI'
	],
	#category : 'NotesMode',
	#package : 'NotesMode'
}

{ #category : 'layout' }
NotesFocusUI class >> defaultLayout [
	"comment stating purpose of class-side method"
	"scope: class-variables  &  class-instance-variables"

	^ self defaultSpec.
]

{ #category : 'specs' }
NotesFocusUI class >> defaultSpec [
	"comment stating purpose of message"

<spec: #default>
	| bodyLayoutSpec |
	bodyLayoutSpec := SpBoxLayout newVertical .
	bodyLayoutSpec add: #text.
			
		^ bodyLayoutSpec .
]

{ #category : 'example' }
NotesFocusUI class >> example [
	^ self new open.
]

{ #category : 'initialization' }
NotesFocusUI >> initializeWidgets [
	"comment stating purpose of message"

	text := self newText.
	text whenBuiltDo: [  :w | w widget font: (LogicalFont familyName: 'Source Sans Pro' pointSize: 16) ].
	self focusOrder add: text.
	
self whenWindowChanged: [ 
	self window whenClosedDo: [ self sentFocusContentsToParent  ]
].
]

{ #category : 'accessing' }
NotesFocusUI >> parentNotesUI [
	^ parentNotesUI
]

{ #category : 'accessing' }
NotesFocusUI >> parentNotesUI: anObject [
	parentNotesUI := anObject
]

{ #category : 'as yet unclassified' }
NotesFocusUI >> sentFocusContentsToParent [
	"comment stating purpose of message"

"self text accept."

self parentNotesUI ifNotNil: [ 
	self parentNotesUI insertStringAtCursor:  ((self text text), String cr). 
	"cast it to a string, not text, to remove formatting. RPW 07/27/2019"
	].
]

{ #category : 'accessing' }
NotesFocusUI >> text [
	^ text
]

{ #category : 'accessing' }
NotesFocusUI >> text: anObject [
	text := anObject
]
