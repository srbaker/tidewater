Class {
	#name : 'TwViewTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwViewTest >> testRendersItsModel [
	| counter |
	counter := TwCounter new.
	self assert: (TwCounterView on: counter) render equals: '<p>0</p>'
]
