Class {
	#name : 'TodoView',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'form',
		'filter'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'instance creation' }
TodoView class >> on: aList [
	^ self new setList: aList
]

{ #category : 'actions' }
TodoView >> actions [
	^ #(#filter:)
]

{ #category : 'composing' }
TodoView >> children [
	^ {form}
]

{ #category : 'actions' }
TodoView >> filter: fields [
	filter := fields at: 'filter' ifAbsent: ['']
]

{ #category : 'rendering' }
TodoView >> renderOn: html [
	html input: {#type -> 'search'. #name -> 'filter'. #value -> filter. #onInput -> #filter. #debounce -> 200}.
	html ul: [self visibleItems do: [:each | html li: each]].
	html render: form
]

{ #category : 'initialization' }
TodoView >> setList: aList [
	list := aList.
	form := TodoForm on: aList.
	filter := ''
]

{ #category : 'rendering' }
TodoView >> visibleItems [
	filter isEmpty ifTrue: [^ list items].
	^ list items select: [:each | each includesString: filter]
]
