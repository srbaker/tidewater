Class {
	#name : 'TodoForm',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'error'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'instance creation' }
TodoForm class >> on: aList [
	^ self new setList: aList
]

{ #category : 'actions' }
TodoForm >> actions [
	^ #(#add:)
]

{ #category : 'actions' }
TodoForm >> add: fields [
	| item |
	item := fields at: 'item' ifAbsent: [''].
	item isEmpty ifTrue: [^ error := 'Item can''t be blank'].
	error := nil.
	list add: item
]

{ #category : 'rendering' }
TodoForm >> renderOn: html [
	error ifNotNil: [html p: error].
	html form: {#onSubmit -> #add} with: [
		html input: {#name -> 'item'. #hook -> #autofocus}.
		html button: 'Add']
]

{ #category : 'initialization' }
TodoForm >> setList: aList [
	list := aList
]
