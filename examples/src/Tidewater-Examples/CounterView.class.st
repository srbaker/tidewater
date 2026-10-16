Class {
	#name : 'CounterView',
	#superclass : 'TwView',
	#instVars : [
		'counter'
	],
	#category : 'Tidewater-Examples'
}

{ #category : 'instance creation' }
CounterView class >> on: aCounter [
	^ self new setCounter: aCounter
]

{ #category : 'actions' }
CounterView >> actions [
	^ #(#increment)
]

{ #category : 'actions' }
CounterView >> increment [
	counter increment
]

{ #category : 'rendering' }
CounterView >> renderOn: html [
	html p: counter count printString.
	html button: {#onClick -> #increment} with: '+'
]

{ #category : 'initialization' }
CounterView >> setCounter: aCounter [
	counter := aCounter
]
