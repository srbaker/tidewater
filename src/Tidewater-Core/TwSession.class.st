Class {
	#name : 'TwSession',
	#superclass : 'Object',
	#instVars : [
		'system',
		'notifications',
		'heartbeat'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwSession class >> on: aSystem [
	^ self on: aSystem notifying: ObjectsCommittedNotification
]

{ #category : 'instance creation' }
TwSession class >> on: aSystem notifying: aNotificationClass [
	^ self new setSystem: aSystem notifications: aNotificationClass
]

{ #category : 'transactions' }
TwSession >> do: aBlock [
	system abortTransaction.
	aBlock value.
	system commitTransaction
]

{ #category : 'watching' }
TwSession >> isAwake [
	^ heartbeat notNil
]

{ #category : 'accessing' }
TwSession >> notifications [
	^ notifications
]

{ #category : 'initialization' }
TwSession >> setSystem: aSystem notifications: aNotificationClass [
	system := aSystem.
	notifications := aNotificationClass
]

{ #category : 'watching' }
TwSession >> stop [
	heartbeat terminate.
	heartbeat := nil
]

{ #category : 'accessing' }
TwSession >> system [
	^ system
]

{ #category : 'watching' }
TwSession >> watch: objects [
	system addAllToNotifySet: objects; enableSignaledObjectsError
]

{ #category : 'watching' }
TwSession >> whenChanged: aBlock [
	notifications addDefaultHandler: [:notification |
		system signaledObjects; enableSignaledObjectsError.
		[system abortTransaction. aBlock value] fork.
		notification resume].
	heartbeat := [[true] whileTrue: [(Delay forMilliseconds: 100) wait]] fork
]
