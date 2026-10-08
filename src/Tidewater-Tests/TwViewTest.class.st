Class {
	#name : 'TwViewTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwViewTest >> testRendersTheCountAndAnIncrementButton [
	| counter |
	counter := TwCounter new.
	counter increment.
	self assert: (TwCounterView on: counter) render equals: '<p>1</p><button tw-click="increment">+</button>'
]

{ #category : 'tests' }
TwViewTest >> testResetsTheCounter [
	| counter view |
	counter := TwCounter new.
	counter increment.
	view := TwCounterView on: counter.
	view reset.
	self assert: counter count equals: 0.
	self assert: (view actions includes: #reset)
]
