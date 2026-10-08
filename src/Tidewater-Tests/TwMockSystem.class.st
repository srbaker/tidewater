Class {
	#name : 'TwMockSystem',
	#superclass : 'Object',
	#instVars : [
		'log'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwMockSystem class >> new [
	^ super new initialize
]

{ #category : 'transactions' }
TwMockSystem >> abortTransaction [
	log add: #abortTransaction
]

{ #category : 'transactions' }
TwMockSystem >> commitTransaction [
	log add: #commitTransaction.
	^ true
]

{ #category : 'initialization' }
TwMockSystem >> initialize [
	log := OrderedCollection new
]

{ #category : 'accessing' }
TwMockSystem >> log [
	^ log
]
