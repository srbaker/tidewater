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
TwAutoView >> render [
	^ ''
]

{ #category : 'initialization' }
TwAutoView >> setModel: aModel [
	model := aModel
]
