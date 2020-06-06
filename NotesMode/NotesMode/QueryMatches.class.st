"
Mostly exists as a container over KindMatches to let us change GTInspector in such a way that it is useful.
"
Class {
	#name : #QueryMatches,
	#superclass : #Object,
	#instVars : [
		'matches'
	],
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
QueryMatches >> gtInspectorCollectionsIn: composite [
	<gtInspectorPresentationOrder: 40>
	<gtInspectorTag: #basic>
	composite list
		title: 'Matches';
		display: [ self matches ];
		format: [ :each | each lineText  ];
		when: [ self matches notEmpty ]
]

{ #category : #accessing }
QueryMatches >> matches [
	^ matches
]

{ #category : #accessing }
QueryMatches >> matches: anObject [
	matches := anObject
]
