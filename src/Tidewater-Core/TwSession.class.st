Class {
	#name : 'TwSession',
	#superclass : 'Object',
	#instVars : [
		'system',
		'changed',
		'poller',
		'mutex'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwSession class >> on: aSystem [
	^ self new setSystem: aSystem
]

{ #category : 'transactions' }
TwSession >> do: aBlock [
	"One transaction serves the whole gem, so actions and refreshes take turns."

	mutex critical: [
		10 timesRepeat: [
			system abortTransaction.
			aBlock value.
			system commitTransaction ifTrue: [^ self]].
		system abortTransaction].
	TwConflict signal: 'Gave up after 10 conflicting commits'
]

{ #category : 'watching' }
TwSession >> isPolling [
	^ poller notNil
]

{ #category : 'watching' }
TwSession >> poll [
	system signaledObjects isEmpty ifTrue: [^ self].
	mutex critical: [
		system abortTransaction.
		changed value]
]

{ #category : 'transactions' }
TwSession >> refresh [
	"See everything committed so far, once no action is in progress."

	mutex critical: [system abortTransaction]
]

{ #category : 'initialization' }
TwSession >> setSystem: aSystem [
	system := aSystem.
	mutex := Semaphore forMutualExclusion
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
