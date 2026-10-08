Class {
	#name : 'TwSession',
	#superclass : 'Object',
	#instVars : [
		'system',
		'notifications'
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

{ #category : 'accessing' }
TwSession >> notifications [
	^ notifications
]

{ #category : 'initialization' }
TwSession >> setSystem: aSystem notifications: aNotificationClass [
	system := aSystem.
	notifications := aNotificationClass
]

{ #category : 'accessing' }
TwSession >> system [
	^ system
]

{ #category : 'watching' }
TwSession >> watch: objects then: aBlock [
	system addAllToNotifySet: objects; enableSignaledObjectsError.
	notifications addDefaultHandler: [:notification |
		system signaledObjects; enableSignaledObjectsError.
		[system abortTransaction. aBlock value] fork.
		notification resume]
]
