"
For hints mayyybee see SpDatePresenter? But really that just uses the underlaying CalendarMorph
"
Class {
	#name : #NotesFocusMonthMorph,
	#superclass : #CalendarMorph,
	#category : 'NotesMode'
}

{ #category : #'as yet unclassified' }
NotesFocusMonthMorph >> announceDate [
	Transcript show: 'we have an announced date'.
	super announceDate.
]

{ #category : #'as yet unclassified' }
NotesFocusMonthMorph >> handleTodayTouched [
"called when we click back to the circled today item"
	Transcript show: 'hello'.
	super handleTodayTouched
]
