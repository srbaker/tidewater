Class {
	#name : 'TwTodoViewTest',
	#superclass : 'TwTestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwTodoViewTest >> testAddsAnItemFromItsFields [
	| list form |
	list := TwTodoList new.
	form := TwTodoForm on: list.
	form add: (Dictionary new at: 'item' put: 'milk'; yourself).
	self assert: list items asArray equals: #('milk').
	self assert: (form actions includes: #add:)
]

{ #category : 'tests' }
TwTodoViewTest >> testNoticesAddedItems [
	| list |
	list := TwTodoList new.
	self assertView: (TwTodoView on: list) noticesChangesBy: [list add: 'milk']
]

{ #category : 'tests' }
TwTodoViewTest >> testRejectsABlankItem [
	| list form |
	list := TwTodoList new.
	form := TwTodoForm on: list.
	form add: (Dictionary new at: 'item' put: ''; yourself).
	self assert: list items isEmpty.
	self assert: (form render includesString: 'Item can''t be blank')
]

{ #category : 'tests' }
TwTodoViewTest >> testRendersItsItemsAndAForm [
	| list view |
	list := TwTodoList new.
	list add: 'milk'.
	view := TwTodoView on: list.
	view id: 'v'.
	self
		assert: view render
		equals: '<ul><li>milk</li></ul><div tw-view="v-1"><form tw-submit="add"><input name="item"><button>Add</button></form></div>'
]
