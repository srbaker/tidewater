Class {
	#name : 'TwRootTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwRootTest >> testClearingATodoListEmptiesItAndTouchesIt [
	| list before |
	list := TwTodoList new.
	list add: 'milk'.
	before := list version.
	list clear.
	self assert: list items isEmpty.
	self deny: list version = before
]

{ #category : 'tests' }
TwRootTest >> testTouchingChangesTheRoot [
	| root before |
	root := TwRoot new.
	before := root version.
	root touch.
	self deny: root version = before
]
