Class {
	#name : 'TwMockNotifications',
	#superclass : 'Object',
	#instVars : [
		'handler'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'handling' }
TwMockNotifications >> addDefaultHandler: aBlock [
	handler := aBlock
]

{ #category : 'signalling' }
TwMockNotifications >> resume [
]

{ #category : 'signalling' }
TwMockNotifications >> signal [
	handler value: self
]
