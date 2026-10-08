Class {
	#name : 'TwRootTest',
	#superclass : 'TestCase',
	#category : 'Tidewater-Tests'
}

{ #category : 'tests' }
TwRootTest >> testTouchingChangesTheRoot [
	| root before |
	root := TwRoot new.
	before := root version.
	root touch.
	self deny: root version = before
]
