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
	^ #(#increment #slowIncrement)
]

{ #category : 'actions' }
TwCounterView >> increment [
	counter increment
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

{ #category : 'actions' }
TwCounterView >> slowIncrement [
	"Waits partway through, as an action calling another service would."

	counter increment.
	(Delay forMilliseconds: 20) wait
]
