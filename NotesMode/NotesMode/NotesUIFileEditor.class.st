"
Class:  I represent a single window where the user can just edit a text file, without all the extra notes mode trimmings.

For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.


    Implementation Points
"
Class {
	#name : #NotesUIFileEditor,
	#superclass : #NotesMarkdownFileEditorWindowBase,
	#instVars : [
		'menu'
	],
	#category : #NotesMode
}

{ #category : #specs }
NotesUIFileEditor class >> defaultSpec [
	<spec: #default>

	
	^ SpecLayout composed
		newColumn: [ :c | 
			c
				add: #menu height: self toolbarHeight;
				add: #text ];
		yourself
]

{ #category : #example }
NotesUIFileEditor class >> example [
	^ self new openWithSpec.
]

{ #category : #initialization }
NotesUIFileEditor >> initializeWidgets [
   |cMenu|
   cMenu := self newMenuBar.
	cMenu
		addGroup: [ :group | 
			super addStandardToolbarItemsTo: group.
			
		].
	
	super initializeWidgets .
]

{ #category : #accessing }
NotesUIFileEditor >> menu [
	^ menu
]

{ #category : #accessing }
NotesUIFileEditor >> menu: anObject [
	menu := anObject
]
