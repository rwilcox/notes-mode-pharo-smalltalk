Class {
	#name : #SnippetsCollection,
	#superclass : #Object,
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
SnippetsCollection >> meetingSnippet [
	^ '### - [MEETING]: ', String cr, String cr, String cr, 
	'| Document                                   | Link                               |', String cr,
   '|  ----------------------------------------  |  --------------------------------  |', String cr,
   '| Meeting URL                                |                                    |', String cr,
   '|                                            |                                    |'


]

{ #category : #'as yet unclassified' }
SnippetsCollection >> worklogSnippet [
	"comment stating purpose of message"

	^ (Date today mmddyyyy , String cr, '=================================', String cr, String cr, 'Notes', String cr, '-------------------------------------', String cr, String cr , String cr, 'Meetings', String cr, '-------------------------------------', String cr, String cr, String cr, 'In Progress', String cr, '---------------------------------------------', String cr, String cr, String cr, 'TODOs', String cr, '-------------------------------------', String cr, String cr, String cr, 'Questions and Answers', String cr, '-------------------------------------', String cr, String cr, String cr, 'Standup Status For Tomorrow', String cr, '-------------------------------------', String cr, String cr, String cr).
			 
]
