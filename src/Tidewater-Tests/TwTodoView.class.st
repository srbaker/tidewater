Class {
	#name : 'TwTodoView',
	#superclass : 'TwView',
	#instVars : [
		'list',
		'form'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwTodoView class >> on: aList [
	^ self new setList: aList
]

{ #category : 'composing' }
TwTodoView >> children [
	^ {form}
]

{ #category : 'rendering' }
TwTodoView >> render [
	| html |
	html := WriteStream on: String new.
	html nextPutAll: '<ul>'.
	list items do: [:each | html nextPutAll: '<li>'; nextPutAll: each; nextPutAll: '</li>'].
	^ html nextPutAll: '</ul>'; nextPutAll: (self render: form); contents
]

{ #category : 'initialization' }
TwTodoView >> setList: aList [
	list := aList.
	form := TwTodoForm on: aList
]

{ #category : 'watching' }
TwTodoView >> watches [
	^ {list}
]
