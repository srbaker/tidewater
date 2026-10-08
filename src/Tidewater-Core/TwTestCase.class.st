Class {
	#name : 'TwTestCase',
	#superclass : 'TestCase',
	#category : 'Tidewater-Core'
}

{ #category : 'asserting' }
TwTestCase >> assertView: aView noticesChangesBy: aBlock [
	| before watched |
	before := aView render copy.
	watched := self stateOfWatchesOf: aView.
	aBlock value.
	aView render = before ifTrue: [^ self].
	self
		assert: (self stateOfWatchesOf: aView) ~= watched
		description: aView class name, ' changed its render, but nothing it watches changed'
]

{ #category : 'private' }
TwTestCase >> stateOf: anObject [
	| named |
	named := (1 to: anObject class instSize) collect: [:i | anObject instVarAt: i].
	anObject class isIndexable ifFalse: [^ named].
	^ named, ((1 to: anObject basicSize) collect: [:i | anObject basicAt: i])
]

{ #category : 'private' }
TwTestCase >> stateOfWatchesOf: aView [
	^ aView watches collect: [:each | self stateOf: each]
]
