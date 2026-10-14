Class {
	#name : 'TwTodoView',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'form',
		'filter'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwTodoView class >> on: aList [
	^ self new setList: aList
]

{ #category : 'actions' }
TwTodoView >> actions [
	^ #(#filter:)
]

{ #category : 'composing' }
TwTodoView >> children [
	^ {form}
]

{ #category : 'actions' }
TwTodoView >> filter: fields [
	filter := fields at: 'filter' ifAbsent: ['']
]

{ #category : 'rendering' }
TwTodoView >> render [
	| html |
	html := WriteStream on: String new.
	html nextPutAll: '<input type="search" name="filter" tw-input="filter" tw-debounce="200" value="', (self escape: filter), '"><ul>'.
	self visibleItems do: [:each | html nextPutAll: '<li>'; nextPutAll: (self escape: each); nextPutAll: '</li>'].
	^ html nextPutAll: '</ul>'; nextPutAll: (self render: form); contents
]

{ #category : 'initialization' }
TwTodoView >> setList: aList [
	list := aList.
	form := TwTodoForm on: aList.
	filter := ''
]

{ #category : 'rendering' }
TwTodoView >> visibleItems [
	filter isEmpty ifTrue: [^ list items].
	^ list items select: [:each | each includesString: filter]
]
