Class {
	#name : 'TwTodoView',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'error'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwTodoView class >> on: aList [
	^ self new setList: aList
]

{ #category : 'actions' }
TwTodoView >> actions [
	^ #(#add:)
]

{ #category : 'actions' }
TwTodoView >> add: fields [
	| item |
	item := fields at: 'item' ifAbsent: [''].
	item isEmpty ifTrue: [^ error := 'Item can''t be blank'].
	error := nil.
	list add: item
]

{ #category : 'rendering' }
TwTodoView >> render [
	| html |
	html := WriteStream on: String new.
	html nextPutAll: '<ul>'.
	list items do: [:each | html nextPutAll: '<li>'; nextPutAll: each; nextPutAll: '</li>'].
	html nextPutAll: '</ul>'.
	error ifNotNil: [html nextPutAll: '<p>'; nextPutAll: error; nextPutAll: '</p>'].
	^ html nextPutAll: '<form tw-submit="add"><input name="item"><button>Add</button></form>'; contents
]

{ #category : 'initialization' }
TwTodoView >> setList: aList [
	list := aList
]

{ #category : 'watching' }
TwTodoView >> watches [
	^ {list}
]
