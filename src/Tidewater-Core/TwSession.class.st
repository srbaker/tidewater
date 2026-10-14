Class {
	#name : 'TwSession',
	#superclass : 'Object',
	#instVars : [
		'system',
		'changed',
		'poller'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwSession class >> on: aSystem [
	^ self new setSystem: aSystem
]

{ #category : 'transactions' }
TwSession >> do: aBlock [
	10 timesRepeat: [
		system abortTransaction.
		aBlock value.
		system commitTransaction ifTrue: [^ self]].
	system abortTransaction.
	TwConflict signal: 'Gave up after 10 conflicting commits'
]

{ #category : 'watching' }
TwSession >> isPolling [
	^ poller notNil
]

{ #category : 'watching' }
TwSession >> poll [
	system signaledObjects isEmpty ifTrue: [^ self].
	system abortTransaction.
	changed value
]

{ #category : 'initialization' }
TwSession >> setSystem: aSystem [
	system := aSystem
]

{ #category : 'watching' }
TwSession >> stop [
	poller terminate.
	poller := nil
]

{ #category : 'accessing' }
TwSession >> system [
	^ system
]

{ #category : 'watching' }
TwSession >> watch: objects [
	system addAllToNotifySet: (objects select: [:each | each isCommitted])
]

{ #category : 'watching' }
TwSession >> whenChanged: aBlock [
	changed := aBlock.
	poller := [[true] whileTrue: [(Delay forMilliseconds: 100) wait. self poll]] fork
]
