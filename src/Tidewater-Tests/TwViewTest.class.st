Class {
	#name : 'TwViewTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwViewTest >> testRendersTheCount [
	| counter |
	counter := TwCounter new.
	counter increment.
	self assert: (TwCounterView on: counter) render equals: '<p>1</p>'
]
