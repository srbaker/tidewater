Class {
	#name : 'TwMockView',
	#superclass : 'TwView',
	#instVars : [
		'html'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwMockView class >> rendering: aString [
	^ self new setHtml: aString
]

{ #category : 'rendering' }
TwMockView >> render [
	^ html
]

{ #category : 'initialization' }
TwMockView >> setHtml: aString [
	html := aString
]
