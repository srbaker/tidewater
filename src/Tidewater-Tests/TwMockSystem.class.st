Class {
	#name : 'TwMockSystem',
	#superclass : 'Object',
	#instVars : [
		'log',
		'watched',
		'signaled'
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

{ #category : 'notifications' }
TwMockSystem >> addAllToNotifySet: aCollection [
	watched := aCollection.
	log add: #addAllToNotifySet:
]

{ #category : 'notifications' }
TwMockSystem >> commitChangeTo: anObject [
	signaled add: anObject
]

{ #category : 'transactions' }
TwMockSystem >> commitTransaction [
	log add: #commitTransaction.
	^ true
]

{ #category : 'initialization' }
TwMockSystem >> initialize [
	log := OrderedCollection new.
	signaled := OrderedCollection new
]

{ #category : 'accessing' }
TwMockSystem >> log [
	^ log
]

{ #category : 'notifications' }
TwMockSystem >> signaledObjects [
	| objects |
	log add: #signaledObjects.
	objects := signaled asArray.
	signaled := OrderedCollection new.
	^ objects
]

{ #category : 'accessing' }
TwMockSystem >> watched [
	^ watched
]
