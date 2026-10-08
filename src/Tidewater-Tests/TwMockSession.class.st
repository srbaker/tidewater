Class {
	#name : 'TwMockSession',
	#superclass : 'Object',
	#instVars : [
		'ran',
		'watched',
		'changed',
		'conflicting'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwMockSession class >> new [
	^ super new initialize
]

{ #category : 'transactions' }
TwMockSession >> beConflicting [
	conflicting := true
]

{ #category : 'watching' }
TwMockSession >> change [
	changed ifNotNil: [:block | block value]
]

{ #category : 'transactions' }
TwMockSession >> do: aBlock [
	ran := true.
	conflicting = true ifTrue: [^ TwConflict signal: 'conflicting'].
	aBlock value.
	self change
]

{ #category : 'testing' }
TwMockSession >> hasRun [
	^ ran = true
]

{ #category : 'initialization' }
TwMockSession >> initialize [
	watched := OrderedCollection new
]

{ #category : 'watching' }
TwMockSession >> watch: objects [
	watched addAll: objects
]

{ #category : 'accessing' }
TwMockSession >> watched [
	^ watched
]

{ #category : 'watching' }
TwMockSession >> whenChanged: aBlock [
	changed := aBlock
]
