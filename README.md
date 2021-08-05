# notes-mode-pharo-smalltalk: An elegant note taking environment

I have been keeping notes, by way of markdown-files-in-a-folder, for a long time. I even developed a structure around these notes. Think [OrgMode](https://orgmode.org/) just not as good.

I originally developed a set of helper scripts as a BBEdit package (still unpublished). Then, as my life became more based around iOS, ported some of those scripts to Editorial (unpublished).

Then my life became very cross-platform, with the addition of a Linux laptop and (a year later) a day job on Windows. I had been using Pharo Smalltalk as a personal developer workspace for a while, so started to port by scripts to Smalltalk.

# Powered by a light syntax over Markdown

There are two forms of items in NotesMode: explicit and implicit named items.

## Explicit Entities

The explicit items have the following structure:

$STUFF - [ENTITY_KIND]: $TEXT

An entity will be considered completed if there's anything between the `-` and the `[`.

An entity can be a single line item, or can extend to multiple lines.

How do you demarcate the difference? By prefixing the line with Markdown heading markers!

Multi line items are defined as content until the Markdown headline changes down one. (So, heading 3 changes to heading 2), or a sibling Markdown element is seen (another heading level 3).

For example:

    - [TODO]: this is a single TODO item

is a single line entity, of TODO kind.

    ### - [TODO]: this is a TODO with some context.

         Bob approves this approach, he said everthing is in place for this.

This is a completed, multi line item:
    ### - (V) [TODO]: this is a TODO item with some context
         Bob approves...
         And it worked the way Bob said it would. Nice job, Bob!

While the NotesMode syntax allows you to create your own entity kind (anything between the `[]`s), we'll call out several entity types you'll often use here:

### Built in Explicit Entities

TODO, ACTION, REVIEW, MEETING, NOTE, REFERENCE, JOURNAL, `NEXT_ACTION`, PROJECT, INBOX

## Implicit Entities

### Wiki words

### tags

### journal entries

    8/4/2021
    =================================

    Notes
    -----------------------------------



     Meetings
     -------------------------------------


     In Progress
     ---------------------------------------------


      TODOs
      -------------------------------------


      Questions and Answers
      -------------------------------------


      Standup Status For Tomorrow
      -------------------------------------



### day list entries

An example day list item is below:

    **** 2012-02-11 (Saturday): ****
    ============================

    Planning
    -------------------------

    <<BBEditNotesPackageThoughts>>
    The nice thing about using markdown is that editors on my iPad and iPhone can open these and make quick edits.

    <<GreatAmericanNovel_ThoughtsOnRoger>>
    Roger is too flat of a character - I need to improve him. What does his past look like?

      #### - [TODO]: Make grocery list

    ### Notes from conversation with Bob RE Feb Acme Quote ###

    Acme Co quote must include more resources than initially planned: the project is on a tighter deadline than originally thought.


    Doing
    -----------------------------

      - Website updating   = [Morning]
      #### - [TODO]: quote for Acme, Co   = [Afternoon]
      - Test at Appeture Science Labs (don't eat dessert - there are rumors of cake!)   = [Afternoon]

    Relaxation
    -----------------------------

      - Guild World of Warcraft raid at 9:00 PM EST
