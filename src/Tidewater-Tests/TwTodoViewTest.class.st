Class {
	#name : 'TwTodoViewTest',
	#superclass : 'TwTestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwTodoViewTest >> testAddsAnItemFromItsFields [
	| list view |
	list := TwTodoList new.
	view := TwTodoView on: list.
	view add: (Dictionary new at: 'item' put: 'milk'; yourself).
	self assert: list items asArray equals: #('milk').
	self assert: (view actions includes: #add:)
]

{ #category : 'tests' }
TwTodoViewTest >> testNoticesAddedItems [
	| list |
	list := TwTodoList new.
	self assertView: (TwTodoView on: list) noticesChangesBy: [list add: 'milk']
]

{ #category : 'tests' }
TwTodoViewTest >> testRejectsABlankItem [
	| list view |
	list := TwTodoList new.
	view := TwTodoView on: list.
	view add: (Dictionary new at: 'item' put: ''; yourself).
	self assert: list items isEmpty.
	self assert: (view render includesString: 'Item can''t be blank')
]

{ #category : 'tests' }
TwTodoViewTest >> testRendersItsItemsAndAForm [
	| list |
	list := TwTodoList new.
	list add: 'milk'.
	self
		assert: (TwTodoView on: list) render
		equals: '<ul><li>milk</li></ul><form tw-submit="add"><input name="item"><button>Add</button></form>'
]
