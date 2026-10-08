Class {
	#name : 'TwTransaction',
	#superclass : 'Object',
	#instVars : [
		'system'
	],
	#category : 'Tidewater-Core'
}

{ #category : 'instance creation' }
TwTransaction class >> on: aSystem [
	^ self new setSystem: aSystem
]

{ #category : 'running' }
TwTransaction >> do: aBlock [
	system abortTransaction.
	aBlock value.
	system commitTransaction
]

{ #category : 'initialization' }
TwTransaction >> setSystem: aSystem [
	system := aSystem
]

{ #category : 'accessing' }
TwTransaction >> system [
	^ system
]
