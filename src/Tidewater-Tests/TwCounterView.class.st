Class {
	#name : 'TwCounterView',
	#superclass : 'Object',
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwCounterView class >> on: aCounter [
	^ self new
]

{ #category : 'rendering' }
TwCounterView >> render [
	^ '<p>0</p>'
]
