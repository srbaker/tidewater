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

{ #category : 'actions' }
TwCounterView >> actions [
	^ #(#increment #reset)
]

{ #category : 'actions' }
TwCounterView >> increment [
	counter increment
]

{ #category : 'rendering' }
TwCounterView >> render [
	^ '<p>', counter count printString, '</p><button tw-click="increment">+</button>'
]

{ #category : 'actions' }
TwCounterView >> reset [
	counter reset
]

{ #category : 'initialization' }
TwCounterView >> setCounter: aCounter [
	counter := aCounter
]

{ #category : 'watching' }
TwCounterView >> watches [
	^ {counter}
]
