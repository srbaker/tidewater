Class {
	#name : 'TwMockSystem',
	#superclass : 'Object',
	#instVars : [
		'log',
		'watched'
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

{ #category : 'transactions' }
TwMockSystem >> commitTransaction [
	log add: #commitTransaction.
	^ true
]

{ #category : 'notifications' }
TwMockSystem >> enableSignaledObjectsError [
	log add: #enableSignaledObjectsError
]

{ #category : 'initialization' }
TwMockSystem >> initialize [
	log := OrderedCollection new
]

{ #category : 'accessing' }
TwMockSystem >> log [
	^ log
]

{ #category : 'notifications' }
TwMockSystem >> signaledObjects [
	log add: #signaledObjects.
	^ #()
]

{ #category : 'accessing' }
TwMockSystem >> watched [
	^ watched
]
