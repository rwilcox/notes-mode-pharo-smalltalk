Class {
	#name : #Tips,
	#superclass : #Object,
	#category : #NotesMode
}

{ #category : #'as yet unclassified' }
Tips class >> tipsAndInformation [
	"comment stating purpose of message"

	Transcript
		show:
			'
Welcome to Note Mode
===========================
';
		show:
			'
This document talks about best practices and usages around using NotesMode in SmallTalk. 
It is NOT meant to be a generic introduction to the syntax etc in NoteMode, which you can
find elsewhere.
';
		show:
			'
# Showing and viewing entities (step 1)
	
I like to create some of my favorite shortcuts in labelled Playground windows, with useful names.
	
## Viewing implicit entities

    |items foundItems|

    items := DiaryFileHelper readDiaryFileAsStream: ''/a/path/to/diary.markdown'' 
      implicitEntityKind: ''wikiword''.

    "QUICK SELECTION SYNTAX HINT: ((each lineText) findString:''Mac'') > 0"
	
## Viewing explicit entities

    |items|

    items := DiaryFileHelper readDiaryFileAsStream: ''/a/path/toa/diary.markdown''
      itemKind: ''TODO'' excludeCompleted: true.

    "QUICK SELECTION SYNTAX HINT: ((each lineText) findString:''Mac'') > 0"

From there, since it''s in a Playground, the Playground''s built in GTInspector takes over.
NotesMode makes good use of the GTInspector.
';
		show:
			'
# Querying

The GTInspector gives us a way to filter through this, and it''s hinted here:

  1. Click Matches
  2. paste that QUICK SELECTION SYNTAX HINT into field: 
  3. ENTER

Now the list will be filtered to items that just contain Mac.
	'.
	Transcript open
]
