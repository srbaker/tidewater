Class {
	#name : 'TwAutoView',
	#superclass : 'TwView',
	#instVars : [
		'model'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwAutoView class >> on: aModel [
	^ self new setModel: aModel
]

{ #category : 'rendering' }
TwAutoView >> renderOn: html [
]

{ #category : 'initialization' }
TwAutoView >> setModel: aModel [
	model := aModel
]
