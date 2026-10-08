Class {
	#name : 'TwMockSession',
	#superclass : 'Object',
	#instVars : [
		'ran',
		'watched',
		'changed'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'watching' }
TwMockSession >> change [
	changed ifNotNil: [:block | block value]
]

{ #category : 'transactions' }
TwMockSession >> do: aBlock [
	ran := true.
	aBlock value.
	self change
]

{ #category : 'testing' }
TwMockSession >> hasRun [
	^ ran = true
]

{ #category : 'watching' }
TwMockSession >> watch: objects then: aBlock [
	watched := objects.
	changed := aBlock
]

{ #category : 'accessing' }
TwMockSession >> watched [
	^ watched
]
