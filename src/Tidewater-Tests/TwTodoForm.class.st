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
TwTodoForm >> render [
	| html |
	html := WriteStream on: String new.
	error ifNotNil: [html nextPutAll: '<p>'; nextPutAll: error; nextPutAll: '</p>'].
	^ html nextPutAll: '<form tw-submit="add"><input name="item"><button>Add</button></form>'; contents
]

{ #category : 'initialization' }
TwTodoForm >> setList: aList [
	list := aList
]
