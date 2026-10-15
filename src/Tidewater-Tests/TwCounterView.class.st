Class {
	#name : 'TwCounterView',
	#superclass : 'TwView',
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
	^ #(#increment)
]

{ #category : 'actions' }
TwCounterView >> increment [
	counter increment
]

{ #category : 'rendering' }
TwCounterView >> render [
	^ '<p>', counter count printString, '</p><button tw-click="increment">+</button>'
]

{ #category : 'rendering' }
TwCounterView >> renderOn: html [
	html p: counter count printString.
	html button: {#onClick -> #increment} with: '+'
]

{ #category : 'initialization' }
TwCounterView >> setCounter: aCounter [
	counter := aCounter
]
