Class {
	#name : #KindMatch,
	#superclass : #Object,
	#instVars : [
		'lineNumber',
		'lineText',
		'kind',
		'completed'
	],
	#category : #NotesMode
}

{ #category : #accessing }
KindMatch >> completed [
	^ completed
]

{ #category : #accessing }
KindMatch >> completed: anObject [
	completed := anObject
]

{ #category : #accessing }
KindMatch >> kind [
	^ kind
]

{ #category : #accessing }
KindMatch >> kind: anObject [
	kind := anObject
]

{ #category : #accessing }
KindMatch >> lineNumber [
	^ lineNumber
]

{ #category : #accessing }
KindMatch >> lineNumber: anObject [
	lineNumber := anObject
]

{ #category : #accessing }
KindMatch >> lineText [
	^ lineText
]

{ #category : #accessing }
KindMatch >> lineText: anObject [
	lineText := anObject
]

{ #category : #'as yet unclassified' }
KindMatch >> textLines [
"A polymorphic method to allow us any easy way to get a string version of the lines in question"
	^ lineText
]
