"
I represent an entity kind that may contain text 'inside"" the  entity.

For example, a day (implicit) entity might have a number of text lines below it.


Internal Representation and Key Implementation Points.

    Instance Variables
	containingLinesArray:		<Object>
	endLineStart:		<Object>


    Implementation Points
"
Class {
	#name : #MultilineKindMatch,
	#superclass : #KindMatch,
	#instVars : [
		'endLineStart',
		'containingLinesArray'
	],
	#category : #NotesModeParser
}

{ #category : #accessing }
MultilineKindMatch >> _containingLinesArray [
	^ containingLinesArray
]

{ #category : #'as yet unclassified' }
MultilineKindMatch >> appendLine: line [
	containingLinesArray addLast: line
]

{ #category : #accessing }
MultilineKindMatch >> endLineStart [
	^ endLineStart
]

{ #category : #accessing }
MultilineKindMatch >> endLineStart: anObject [
	endLineStart := anObject
]

{ #category : #'as yet unclassified' }
MultilineKindMatch >> initialize [
	containingLinesArray := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
MultilineKindMatch >> textLines [
	"comment stating purpose of message"

	^ Utils easyJoinArray: containingLinesArray.
]
