Class {
	#name : 'TwMockSocket',
	#superclass : 'Object',
	#instVars : [
		'written',
		'whileOpen'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwMockSocket class >> whileOpen: aBlock [
	^ self new setWhileOpen: aBlock
]

{ #category : 'socket' }
TwMockSocket >> readWillNotBlockWithin: milliseconds [
	whileOpen value.
	^ true
]

{ #category : 'initialization' }
TwMockSocket >> setWhileOpen: aBlock [
	whileOpen := aBlock.
	written := OrderedCollection new
]

{ #category : 'socket' }
TwMockSocket >> write: aString [
	written add: aString.
	^ aString size
]

{ #category : 'accessing' }
TwMockSocket >> written [
	^ written
]
