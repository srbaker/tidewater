Class {
	#name : 'TwTodoView',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'form',
		'filter'
	],
	#category : 'Tidewater-Examples'
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
TwTodoView >> renderOn: html [
	html input: {#type -> 'search'. #name -> 'filter'. #value -> filter. #onInput -> #filter. #debounce -> 200}.
	html ul: [self visibleItems do: [:each | html li: each]].
	html render: form
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
