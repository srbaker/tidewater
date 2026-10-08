Class {
	#name : 'TwTodoView',
	#superclass : 'Object',
	#instVars : [
		'list'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwTodoView class >> on: aList [
	^ self new setList: aList
]

{ #category : 'rendering' }
TwTodoView >> render [
	| html |
	html := WriteStream on: String new.
	html nextPutAll: '<ul>'.
	list items do: [:each | html nextPutAll: '<li>'; nextPutAll: each; nextPutAll: '</li>'].
	^ html nextPutAll: '</ul>'; contents
]

{ #category : 'initialization' }
TwTodoView >> setList: aList [
	list := aList
]

{ #category : 'watching' }
TwTodoView >> watches [
	^ {list}
]
