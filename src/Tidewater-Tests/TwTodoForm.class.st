Class {
	#name : 'TwTodoForm',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'error'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwTodoForm class >> on: aList [
	^ self new setList: aList
]

{ #category : 'actions' }
TwTodoForm >> actions [
	^ #(#add:)
]

{ #category : 'actions' }
TwTodoForm >> add: fields [
	| item |
	item := fields at: 'item' ifAbsent: [''].
	item isEmpty ifTrue: [^ error := 'Item can''t be blank'].
	error := nil.
	list add: item
]

{ #category : 'rendering' }
TwTodoForm >> renderOn: html [
	error ifNotNil: [html p: error].
	html form: {#onSubmit -> #add} with: [
		html input: {#name -> 'item'. #hook -> #autofocus}.
		html button: 'Add']
]

{ #category : 'initialization' }
TwTodoForm >> setList: aList [
	list := aList
]
