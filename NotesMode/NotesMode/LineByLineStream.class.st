"
Fakes a stream that has a do loop based on lines, not characters.

This is all.
"
Class {
	#name : #LineByLineStream,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
LineByLineStream >> do: aBlock [
	[ (self stream) atEnd ] whileFalse: [ aBlock value: (self stream) nextLine ]
]

{ #category : #accessing }
LineByLineStream >> stream [
	^ stream
]

{ #category : #accessing }
LineByLineStream >> stream: anObject [
	stream := anObject
]
