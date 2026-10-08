Class {
	#name : 'TwCounterView',
	#superclass : 'Object',
	#instVars : [
		'counter'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwCounterView class >> on: aCounter [
	^ self new setCounter: aCounter
]

{ #category : 'rendering' }
TwCounterView >> render [
	^ '<p>', counter count printString, '</p>'
]

{ #category : 'initialization' }
TwCounterView >> setCounter: aCounter [
	counter := aCounter
]
