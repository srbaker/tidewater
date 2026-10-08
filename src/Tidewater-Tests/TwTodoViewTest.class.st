Class {
	#name : 'TwTodoViewTest',
	#superclass : 'TwTestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwTodoViewTest >> testNoticesAddedItems [
	| list |
	list := TwTodoList new.
	self assertView: (TwTodoView on: list) noticesChangesBy: [list add: 'milk']
]
