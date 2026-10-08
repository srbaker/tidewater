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
TwTodoViewTest >> testEscapesWhatPeopleType [
	| list view |
	list := TwTodoList new.
	list add: '<script>'.
	view := TwTodoView on: list.
	view filter: (Dictionary new at: 'filter' put: '"><'; yourself).
	self deny: (view render includesString: '<script>').
	self assert: (view render includesString: 'value="&quot;&gt;&lt;"')
]

{ #category : 'tests' }
TwTodoViewTest >> testFiltersItsItems [
	| list view |
	list := TwTodoList new.
	list add: 'milk'; add: 'eggs'.
	view := TwTodoView on: list.
	view filter: (Dictionary new at: 'filter' put: 'mi'; yourself).
	self assert: (view render includesString: '<ul><li>milk</li></ul>').
	self assert: (view render includesString: 'value="mi"').
	self assert: (view actions includes: #filter:)
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
		equals: '<input type="search" name="filter" tw-input="filter" tw-debounce="200" value=""><ul><li>milk</li></ul><div tw-view="v-1"><form tw-submit="add"><input name="item"><button>Add</button></form></div>'
]
