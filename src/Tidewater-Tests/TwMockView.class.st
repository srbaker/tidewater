Class {
	#name : 'TwMockView',
	#superclass : 'TwView',
	#instVars : [
		'html',
		'children',
		'watches'
	],
	#category : 'Tidewater-Tests'
}

{ #category : 'instance creation' }
TwMockView class >> rendering: aString [
	^ self new setHtml: aString
]

{ #category : 'instance creation' }
TwMockView class >> rendering: aString children: anArray [
	^ (self rendering: aString) setChildren: anArray
]

{ #category : 'instance creation' }
TwMockView class >> watching: anArray children: aCollection [
	^ ((self rendering: '') setChildren: aCollection) setWatches: anArray
]

{ #category : 'composing' }
TwMockView >> children [
	^ children ifNil: [#()]
]

{ #category : 'rendering' }
TwMockView >> render [
	^ html
]

{ #category : 'initialization' }
TwMockView >> setChildren: anArray [
	children := anArray
]

{ #category : 'initialization' }
TwMockView >> setHtml: aString [
	html := aString
]

{ #category : 'initialization' }
TwMockView >> setWatches: anArray [
	watches := anArray
]

{ #category : 'watching' }
TwMockView >> watches [
	^ watches ifNil: [#()]
]
